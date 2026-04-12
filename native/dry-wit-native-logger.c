#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
  if (colors_enabled) {
    fprintf(stdout, "[%s %s%s\033[0m] %s", timestamp, level_color(level), level, message);
  } else {
    fprintf(stdout, "[%s %s] %s", timestamp, level, message);
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
  int outcome_length = (int) strlen(text) + 2;

  if (term_width > 0 && strcmp(alignment_mode, "none") != 0) {
    int current_column = (line_length % term_width) + 1;
    int target_column = term_width - outcome_length + 1;

    if (strcmp(alignment_mode, "padding") == 0) {
      int offset = term_width - ((line_length + outcome_length) % term_width) + 1;
      if (offset > 0) {
        print_repeated(stdout, separator, offset);
      }
    } else {
      if (current_column > target_column) {
        fputc('\n', stdout);
      }
      fprintf(stdout, "\033[%dG", target_column);
    }
  } else {
    fputs(" ... ", stdout);
  }

  if (colors_enabled) {
    fprintf(stdout, "[%s%s\033[0m]", outcome_color(keyword), text);
  } else {
    fprintf(stdout, "[%s]", text);
  }

  return 0;
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "Usage: %s message|outcome ...\n", argv[0]);
    return 1;
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
