#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static FILE *output_stream = NULL;

static const char *level_color(const char *level) {
  if (strcmp(level, "TRACE") == 0) {
    return "\033[36m";
  }
  if (strcmp(level, "DEBUG") == 0) {
    return "\033[35m";
  }
  if (strcmp(level, "INFO") == 0) {
    return "\033[32m";
  }
  if (strcmp(level, "WARN") == 0) {
    return "\033[33m";
  }
  if (strcmp(level, "ERROR") == 0) {
    return "\033[31m";
  }

  return "\033[37m";
}

static const char *outcome_color(const char *keyword) {
  if (strcmp(keyword, "SUCCESS") == 0) {
    return "\033[32m";
  }
  if (strcmp(keyword, "FAILURE") == 0) {
    return "\033[31m";
  }
  if (strcmp(keyword, "NEUTRAL") == 0) {
    return "\033[33m";
  }
  if (strcmp(keyword, "IN_PROGRESS") == 0) {
    return "\033[34m";
  }

  return "\033[37m";
}

static void print_repeated(FILE *stream, const char *separator, int count) {
  int i;
  char fill = ' ';

  if (separator != NULL && separator[0] != '\0') {
    fill = separator[0];
  }

  for (i = 0; i < count; i++) {
    fputc(fill, stream);
  }
}

static int print_message(const char *timestamp, const char *level, const char *message, int colors_enabled) {
  FILE *stream = output_stream != NULL ? output_stream : stdout;

  if (colors_enabled) {
    fprintf(stream, "[%s %s%s\033[0m] %s", timestamp, level_color(level), level, message);
  } else {
    fprintf(stream, "[%s %s] %s", timestamp, level, message);
  }

  return 0;
}

static int print_outcome(
  int line_length,
  int term_width,
  const char *alignment_mode,
  const char *separator,
  const char *keyword,
  const char *text,
  int colors_enabled) {
  FILE *stream = output_stream != NULL ? output_stream : stdout;
  int outcome_length = (int) strlen(text) + 2;

  if (term_width > 0 && strcmp(alignment_mode, "none") != 0) {
    int current_column = (line_length % term_width) + 1;
    int target_column = term_width - outcome_length + 1;

    if (strcmp(alignment_mode, "padding") == 0) {
      int offset = term_width - ((line_length + outcome_length) % term_width) + 1;
      if (offset > 0) {
        print_repeated(stream, separator, offset);
      }
    } else {
      if (current_column > target_column) {
        fputc('\n', stream);
      }
      fprintf(stream, "\033[%dG", target_column);
    }
  } else {
    fputs(" ... ", stream);
  }

  if (colors_enabled) {
    fprintf(stream, "[%s%s\033[0m]", outcome_color(keyword), text);
  } else {
    fprintf(stream, "[%s]", text);
  }

  return 0;
}

static int read_line(FILE *stream, char *buffer, size_t size) {
  size_t length;

  if (fgets(buffer, (int) size, stream) == NULL) {
    return 0;
  }

  length = strlen(buffer);
  if (length > 0 && buffer[length - 1] == '\n') {
    buffer[length - 1] = '\0';
  }

  return 1;
}

static char *read_payload(FILE *stream, int length) {
  char *buffer;
  int delimiter;
  size_t offset = 0;

  if (length < 0) {
    return NULL;
  }

  buffer = malloc((size_t) length + 1);
  if (buffer == NULL) {
    return NULL;
  }

  while (offset < (size_t) length) {
    size_t read_now = fread(buffer + offset, 1, (size_t) length - offset, stream);
    if (read_now == 0) {
      free(buffer);
      return NULL;
    }
    offset += read_now;
  }

  buffer[length] = '\0';
  delimiter = fgetc(stream);
  if (delimiter == EOF) {
    free(buffer);
    return NULL;
  }

  return buffer;
}

static FILE *resolve_output_stream(void) {
  const char *output_fd_env = getenv("DW_NATIVE_LOGGER_OUTPUT_FD");

  if (output_fd_env != NULL && output_fd_env[0] != '\0') {
    int output_fd = atoi(output_fd_env);
    if (output_fd > 0) {
      FILE *stream = fdopen(output_fd, "w");
      if (stream != NULL) {
        return stream;
      }
    }
  }

  return stdout;
}

static int daemon_loop(void) {
  char command[32];
  char timestamp[128];
  char level[32];
  char alignment_mode[32];
  char keyword[32];
  char value[64];

  output_stream = resolve_output_stream();
  if (output_stream == NULL) {
    return 1;
  }

  while (read_line(stdin, command, sizeof(command))) {
    int result = 1;

    if (strcmp(command, "message") == 0) {
      char *message = NULL;

      if (!read_line(stdin, timestamp, sizeof(timestamp)) ||
        !read_line(stdin, level, sizeof(level)) ||
        !read_line(stdin, value, sizeof(value))) {
        return 1;
      }

      message = read_payload(stdin, atoi(value));
      if (message == NULL) {
        return 1;
      }

      if (!read_line(stdin, value, sizeof(value))) {
        free(message);
        return 1;
      }

      result = print_message(timestamp, level, message, atoi(value));
      free(message);
    } else if (strcmp(command, "outcome") == 0) {
      char separator_length_text[64];
      char text_length_text[64];
      char *separator = NULL;
      char *text = NULL;
      int line_length;
      int term_width;
      int colors_enabled;

      if (!read_line(stdin, value, sizeof(value))) {
        return 1;
      }
      line_length = atoi(value);
      if (!read_line(stdin, value, sizeof(value))) {
        return 1;
      }
      term_width = atoi(value);

      if (!read_line(stdin, alignment_mode, sizeof(alignment_mode)) ||
        !read_line(stdin, keyword, sizeof(keyword)) ||
        !read_line(stdin, separator_length_text, sizeof(separator_length_text))) {
        return 1;
      }

      separator = read_payload(stdin, atoi(separator_length_text));
      if (separator == NULL) {
        return 1;
      }

      if (!read_line(stdin, text_length_text, sizeof(text_length_text))) {
        free(separator);
        return 1;
      }

      text = read_payload(stdin, atoi(text_length_text));
      if (text == NULL) {
        free(separator);
        return 1;
      }

      if (!read_line(stdin, value, sizeof(value))) {
        free(separator);
        free(text);
        return 1;
      }
      colors_enabled = atoi(value);

      result = print_outcome(
        line_length,
        term_width,
        alignment_mode,
        separator,
        keyword,
        text,
        colors_enabled);

      free(separator);
      free(text);
    } else {
      return 1;
    }

    fflush(output_stream);
    fprintf(stdout, "%d\n", result);
    fflush(stdout);
  }

  return 0;
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "Usage: %s message|outcome|daemon ...\n", argv[0]);
    return 1;
  }

  if (strcmp(argv[1], "daemon") == 0) {
    return daemon_loop();
  }

  if (strcmp(argv[1], "message") == 0) {
    if (argc != 6) {
      fprintf(stderr, "Usage: %s message <timestamp> <level> <message> <colors-enabled>\n", argv[0]);
      return 1;
    }

    return print_message(argv[2], argv[3], argv[4], atoi(argv[5]));
  }

  if (strcmp(argv[1], "outcome") == 0) {
    if (argc != 9) {
      fprintf(stderr, "Usage: %s outcome <line-length> <term-width> <alignment-mode> <separator> <keyword> <text> <colors-enabled>\n", argv[0]);
      return 1;
    }

    return print_outcome(
      atoi(argv[2]),
      atoi(argv[3]),
      argv[4],
      argv[5],
      argv[6],
      argv[7],
      atoi(argv[8]));
  }

  fprintf(stderr, "Unknown command: %s\n", argv[1]);
  return 1;
}
