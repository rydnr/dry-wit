#!/bin/bash dry-wit
# Copyright 2009 Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-v[v]]] [-q|--quiet] [-d|--dry-run] [-a|--audio id]* [-s|--subtitle id]* [-S|--skip-crop-detection] dvd-track output-file
$SCRIPT_NAME [-v[v]]] [-q|--quiet] [-d|--dry-run] [-a|--audio id]* [-s|--subtitle id]* [-S|--skip-crop-detection] input-file output-file
$SCRIPT_NAME [-h|--help]
(c) 2009 Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3
 
Converts a DVD track or video file to 2-pass divx for video, mp3 for audio.
 
Where:
  * dvd-track: The number of the track to rip and convert in the DVD.
  * output-file: The output file.
  * input-file: The input file.
  * -d|--dry-run: Prints what it would do, but does not do it.
  * -a|--audio: The audio id (use lsdvd or press # in mplayer to find out,
     or let $SCRIPT_NAME figure it out using your LANG environment variable).
  * -s|--subtitle: The audio id (use lsdvd or press J in mplayer to find out,
     or let $SCRIPT_NAME figure it out using your LANG environment variable).
  * -S|--skip-crop-detection: Skips the crop detection step.
EOF
}
 
# Requirements
function checkRequirements() {
  checkReq mplayer MPLAYER_NOT_INSTALLED;
  checkReq mencoder MENCODER_NOT_INSTALLED;
  checkReq lsdvd LSDVD_NOT_INSTALLED;
  checkReq avimerge AVIMERGE_NOT_INSTALLED;
  checkReq tccat TCCAT_NOT_INSTALLED;
  checkReq tcextract TCEXTRACT_NOT_INSTALLED;
  checkReq subtitle2pgm SUBTITLE2PGM_NOT_INSTALLED;
  checkReq pgm2txt PGM2TXT_NOT_INSTALLED;
  checkReq srttool SRTTOOL_NOT_INSTALLED;
  checkReq ispell ISPELL_NOT_INSTALLED;
}
 
# Environment
function defineEnv() {
  export CONTENT_TYPE_DEFAULT="movie";
  export CONTENT_TYPE_DESCRIPTION="The media type: either 'movie' or 'cartoon'";
  if    [ "${CONTENT_TYPE+1}" != "1" ] \
     || [ "x${CONTENT_TYPE}" == "x" ]; then
    export CONTENT_TYPE="${CONTENT_TYPE_DEFAULT}";
  fi

  export DVD_DEVICE_DEFAULT="/dev/dvd";
  export DVD_DEVICE_DESCRIPTION="The dvd device";
  if [ "${DVD_DEVICE+1}" != "1" ]; then
    export DVD_DEVICE="${DVD_DEVICE_DEFAULT}";
  fi

  export AUDIO_LANG_DEFAULT="`echo $LANG | cut -d '_' -f 1`";
  export AUDIO_LANG_DESCRIPTION="The audio language (in two-digits ISO format: en, es, fr...)";
  if [ "${AUDIO_LANG+1}" != "1" ]; then
    export AUDIO_LANG="${AUDIO_LANG_DEFAULT}";
  fi
  
  export SUBTITLE_LANG_DEFAULT="`echo $LANG | cut -d '_' -f 1`";
  export SUBTITLE_LANG_DESCRIPTION="The subtitle language (in two-digits ISO format: en, es, fr...)";
  if [ "${SUBTITLE_LANG+1}" != "1" ]; then
    export SUBTITLE_LANG="${SUBTITLE_LANG_DEFAULT}";
  fi
  
  export RIP_EXTRA_LANG_DEFAULT="en";
  export RIP_EXTRA_LANG_DESCRIPTION="Rip based on AUDIO_LANG/SUBTITLE_LANG, and also include audio and subtitles for given different language(s)";
  if [ "${RIP_EXTRA_LANG+1}" != "1" ]; then
    export RIP_EXTRA_LANG="${RIP_EXTRA_LANG_DEFAULT}";
  fi
  
  export LOWEST_QUALITY_DEFAULT="1148";
  export LOWEST_QUALITY_DESCRIPTION="The lowest/fastest coding scheme";
  if [ "${LOWEST_QUALITY+1}" != "1" ]; then
    export LOWEST_QUALITY="${LOWEST_QUALITY_DEFAULT}";
  fi

  export LOW_QUALITY_DEFAULT="1246";
  export LOW_QUALITY_DESCRIPTION="A low/fast coding scheme";
  if [ "${LOW_QUALITY+1}" != "1" ]; then
    export LOW_QUALITY="${LOW_QUALITY_DEFAULT}";
  fi

  export REGULAR_QUALITY_DEFAULT="1443";
  export REGULAR_QUALITY_DESCRIPTION="A fast yet good enough coding scheme";
  if [ "${REGULAR_QUALITY+1}" != "1" ]; then
    export REGULAR_QUALITY="${REGULAR_QUALITY_DEFAULT}";
  fi

  export GOOD_QUALITY_DEFAULT="2428";
  export GOOD_QUALITY_DESCRIPTION="A good quality coding scheme";
  if [ "${GOOD_QUALITY+1}" != "1" ]; then
    export GOOD_QUALITY="${GOOD_QUALITY_DEFAULT}";
  fi

  export HIGH_QUALITY_DEFAULT="2625";
  export HIGH_QUALITY_DESCRIPTION="A even better coding scheme";
  if [ "${HIGH_QUALITY+1}" != "1" ]; then
    export HIGH_QUALITY="${HIGH_QUALITY_DEFAULT}";
  fi

  export HIGHEST_QUALITY_DEFAULT="3020";
  export HIGHEST_QUALITY_DESCRIPTION="An insane quality coding scheme";
  if [ "${HIGHEST_QUALITY+1}" != "1" ]; then
    export HIGHEST_QUALITY="${HIGHEST_QUALITY_DEFAULT}";
  fi

  export QUALITY_DEFAULT="high";
  export QUALITY_DESCRIPTION="The desired quality, one of 'lowest', 'low', 'regular', 'good', 'high', 'highest'";
  if [ "${QUALITY+1}" != "1" ]; then
    export QUALITY="${QUALITY_DEFAULT}";
  fi

  case ${QUALITY} in
    "lowest") export BITRATE="${LOWEST_QUALITY}";
              ;;
    "low") export BITRATE="${LOW_QUALITY}";
           ;;
    "regular") export BITRATE="${REGULAR_QUALITY}";
               ;;
    "good") export BITRATE="${GOOD_QUALITY}";
            ;;
    "high") export BITRATE="${HIGH_QUALITY}";
            ;;
    "highest") export BITRATE="${HIGHEST_QUALITY}";
               ;;
    *) exitWithErrorCode INVALID_QUALITY;
       ;;
  esac

  export VIDEO_WIDTH_DEFAULT="";
  export VIDEO_WIDTH_DESCRIPTION="The width of the output video file"
  if [ "${VIDEO_WIDTH+1}" != "1" ]; then
    export VIDEO_WIDTH="${VIDEO_WIDTH_DEFAULT}";
  fi

  export COMMON_VIDEO_OPTS_FIRST_PASS_DEFAULT="-forceidx -vf pp,harddup -ni";
  export COMMON_VIDEO_OPTS_FIRST_PASS_DESCRIPTION="The video options for the first pass, common for all coding schemes";
  if [ "${COMMON_VIDEO_OPTS_FIRST_PASS+1}" != "1" ]; then
    export COMMON_VIDEO_OPTS_FIRST_PASS="${COMMON_VIDEO_OPTS_FIRST_PASS_DEFAULT}";
  fi

#  export VIDEO_OPTS_MPEG4_FIRST_PASS_DEFAULT="-ovc lavc -lavcopts vcodec=mpeg4:vbitrate=$BITRATE:vhq:vpass=1:vqmin=1:vqmax=31 -vf scale -zoom -xy ${VIDEO_WIDTH} -vf pp,scale";
  export VIDEO_OPTS_MPEG4_FIRST_PASS_DEFAULT="${COMMON_VIDEO_OPTS_FIRST_PASS} -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=${BITRATE}:vhq:vpass=1:vqmin=1:vqmax=31";
  export VIDEO_OPTS_MPEG4_FIRST_PASS_DESCRIPTION="The video options for the first pass, for mpeg4 encoding";
  if [ "${VIDEO_OPTS_MPEG4_FIRST_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_MPEG4_FIRST_PASS="${VIDEO_OPTS_MPEG4_FIRST_PASS_DEFAULT}";
  fi

  export VIDEO_OPTS_XVID_LAVC_FIRST_PASS_DEFAULT="${VIDEO_OPTS_MPEG4_FIRST_PASS} -ffourcc XVID";
  export VIDEO_OPTS_XVID_LAVC_FIRST_PASS_DESCRIPTION="The video options for the first pass, for XviD encoding";
  if [ "${VIDEO_OPTS_XVID_LAVC_FIRST_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_XVID_LAVC_FIRST_PASS="${VIDEO_OPTS_XVID_LAVC_FIRST_PASS_DEFAULT}";
  fi

  export VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS_DEFAULT="${COMMON_VIDEO_OPTS_FIRST_PASS} -ovc xvid -xvidencopts pass=1:turbo=2:bitrate=${BITRATE}:autoaspect:threads=2";
  export VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS_DESCRIPTION="The video options for the second pass, for XviD encoding, using xvidenc";
  if [ "${VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS="${VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS_DEFAULT}";
  fi

  export VIDEO_OPTS_H264_FIRST_PASS_DEFAULT="${COMMON_VIDEO_OPTS_FIRST_PASS} -ovc x264 -x264encopts threads=auto:partitions=all:subq=5:8x8dct:frameref=2:bframes=3:b_pyramid:weight_b:pass=1:turbo=2:bitrate=$BITRATE -ffourcc h264";
  export VIDEO_OPTS_H264_FIRST_PASS_DESCRIPTION="The video options for the first pass, for H.264 encoding";
  if [ "${VIDEO_OPTS_H264_FIRST_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_H264_FIRST_PASS="${VIDEO_OPTS_H264_FIRST_PASS_DEFAULT}";
  fi

  export VIDEO_CODEC_DEFAULT="XviD";
  export VIDEO_CODEC_DESCRIPTION="The video codec to use";
  if    [ "${VIDEO_CODEC+1}" != "1" ] \
     || [ "x${VIDEO_CODEC}" == "x" ]; then
    export VIDEO_CODEC="${VIDEO_CODEC_DEFAULT}";
  fi

  export AUDIO_OPTS_FIRST_PASS_DEFAULT="-nosound";
  export AUDIO_OPTS_FIRST_PASS_DESCRIPTION="The audio options for the first pass" 
  if [ "${AUDIO_OPTS_FIRST_PASS+1}" != "1" ]; then
    export AUDIO_OPTS_FIRST_PASS="${AUDIO_OPTS_FIRST_PASS_DEFAULT}";
  fi

  export COMMON_VIDEO_OPTS_SECOND_PASS_DEFAULT="-forceidx -vf pp,harddup -ni";
  export COMMON_VIDEO_OPTS_SECOND_PASS_DESCRIPTION="The video options for the second pass, common for all coding schemes";
  if [ "${COMMON_VIDEO_OPTS_SECOND_PASS+1}" != "1" ]; then
    export COMMON_VIDEO_OPTS_SECOND_PASS="${COMMON_VIDEO_OPTS_SECOND_PASS_DEFAULT}";
  fi

#  export VIDEO_OPTS_MPEG4_SECOND_PASS_DEFAULT="-ovc lavc -lavcopts vcodec=mpeg4:vbitrate=${BITRATE}:vhq:vpass=2:vqmin=1:vqmax=31 -vf scale -zoom -xy ${VIDEO_WIDTH} -vf pp,scale -forceidx";
  export VIDEO_OPTS_MPEG4_SECOND_PASS_DEFAULT="${COMMON_VIDEO_OPTS_SECOND_PASS} -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=${BITRATE}:vhq:vpass=2:vqmin=1:vqmax=31";
  export VIDEO_OPTS_MPEG4_SECOND_PASS_DESCRIPTION="The video options for the second pass, for mpeg4 encoding";
  if [ "${VIDEO_OPTS_MPEG4_SECOND_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_MPEG4_SECOND_PASS="${VIDEO_OPTS_MPEG4_SECOND_PASS_DEFAULT}";
  fi

  export VIDEO_OPTS_XVID_LAVC_SECOND_PASS_DEFAULT="${VIDEO_OPTS_MPEG4_SECOND_PASS} -ffourcc XVID";
  export VIDEO_OPTS_XVID_LAVC_SECOND_PASS_DESCRIPTION="The video options for the second pass, for XviD encoding, using lavc";
  if [ "${VIDEO_OPTS_XVID_LAVC_SECOND_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_XVID_LAVC_SECOND_PASS="${VIDEO_OPTS_XVID_LAVC_SECOND_PASS_DEFAULT}";
  fi

  export VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS_DEFAULT="${COMMON_VIDEO_OPTS_SECOND_PASS} -ovc xvid -xvidencopts pass=2:turbo=2:bitrate=${BITRATE}:autoaspect:threads=2";
  export VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS_DESCRIPTION="The video options for the second pass, for XviD encoding, using xvidenc";
  if [ "${VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS="${VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS_DEFAULT}";
  fi

  export VIDEO_OPTS_H264_SECOND_PASS_DEFAULT="${COMMON_VIDEO_OPTS_SECOND_PASS} -ovc x264 -x264encopts subq=5:8x8dct:frameref=2:bframes=3:b_pyramid:weight_b:pass=2:bitrate=$BITRATE -ffourcc h264";
  export VIDEO_OPTS_H264_SECOND_PASS_DESCRIPTION="The video options for the second pass, for XviD encoding";
  if [ "${VIDEO_OPTS_H264_SECOND_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_H264_SECOND_PASS="${VIDEO_OPTS_H264_SECOND_PASS_DEFAULT}";
  fi

  case "`echo ${VIDEO_CODEC}-${CONTENT_TYPE} | tr [:upper:] [:lower:]`" in
    "xvid-movie") export VIDEO_OPTS_FIRST_PASS="${VIDEO_OPTS_XVID_LAVC_FIRST_PASS_DEFAULT}";
                  export VIDEO_OPTS_SECOND_PASS="${VIDEO_OPTS_XVID_LAVC_SECOND_PASS_DEFAULT}";
                  ;;
    "xvid-cartoon") export VIDEO_OPTS_FIRST_PASS="`echo ${VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS_DEFAULT} | sed 's_opts _opts cartoon:_g'`";
                    export VIDEO_OPTS_SECOND_PASS="`echo ${VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS_DEFAULT} | sed 's_opts _opts cartoon:_g'`";
                    ;;
    "mpeg4-movie") export VIDEO_OPTS_FIRST_PASS="${VIDEO_OPTS_MPEG4_FIRST_PASS_DEFAULT}";
                   export VIDEO_OPTS_SECOND_PASS="${VIDEO_OPTS_H264_SECOND_PASS_DEFAULT}";
                   ;;
    "mpeg4-cartoon") export VIDEO_OPTS_FIRST_PASS="${VIDEO_OPTS_MPEG4_FIRST_PASS_DEFAULT}";
                   export VIDEO_OPTS_SECOND_PASS="${VIDEO_OPTS_H264_SECOND_PASS_DEFAULT}";
                   ;;
    "h264-movie") export VIDEO_OPTS_FIRST_PASS="${VIDEO_OPTS_H264_FIRST_PASS_DEFAULT}";
                  export VIDEO_OPTS_SECOND_PASS="${VIDEO_OPTS_H264_SECOND_PASS_DEFAULT}";
                  ;;
    "h264-cartoon") export VIDEO_OPTS_FIRST_PASS="${VIDEO_OPTS_H264_FIRST_PASS_DEFAULT}";
                    export VIDEO_OPTS_SECOND_PASS="${VIDEO_OPTS_H264_SECOND_PASS_DEFAULT}";
                    ;;
  esac

  export AUDIO_OPTS_SECOND_PASS_DEFAULT="-oac mp3lame -lameopts vbr=0 -srate 48000";
  export AUDIO_OPTS_SECOND_PASS_DESCRIPTION="The audio options for the second pass" 
  if [ "${AUDIO_OPTS_SECOND_PASS+1}" != "1" ]; then
    export AUDIO_OPTS_SECOND_PASS="${AUDIO_OPTS_SECOND_PASS_DEFAULT}";
  fi

  export AUDIO_CHANNELS_DEFAULT="";
  export AUDIO_CHANNELS_DESCRIPTION="The number of audio channels";
  if [ "${AUDIO_CHANNELS+1}" != "1" ]; then
    export AUDIO_CHANNELS="${AUDIO_CHANNELS_DEFAULT}";
  fi

  export CROP_DETECTION_START_DEFAULT="1200";
  export CROP_DETECTION_START_DESCRIPTION="The point in time in the movie the crop detection will take place";
  if [ "${CROP_DETECTION_START+1}" != "1" ]; then
    export CROP_DETECTION_START="${CROP_DETECTION_START_DEFAULT}";
  fi

  export CROP_DETECTION_DURATION_DEFAULT="3";
  export CROP_DETECTION_DURATION_DESCRIPTION="The number of seconds the movie will be played to find out the optimal crop window";
  if [ "${CROP_DETECTION_DURATION+1}" != "1" ]; then
    export CROP_DETECTION_DURATION="${CROP_DETECTION_DURATION_DEFAULT}";
  fi

  export DVD_COPY_EXTRA_OPTS_DEFAULT="";
  export DVD_COPY_EXTRA_OPTS_DESCRIPTION="Any extra arguments for mplayer when copying the DVD";
  if [ "${DVD_COPY_EXTRA_OPTS+1}" != "1" ]; then
    export DVD_COPY_EXTRA_OPTS="${DVD_COPY_EXTRA_OPTS_DEFAULT}";
  fi

  export DISABLE_EJECT_DEFAULT="";
  export DISABLE_EJECT_DESCRIPTION="Disables the step of trying to eject the disk after copy it to hard disk";
  if [ "${DISABLE_EJECT+1}" != "1" ]; then
    export DISABLE_EJECT="${DISABLE_EJECT_DEFAULT}";
  fi

  export SUBTITLE_GREY_LEVELS_DEFAULT="255,255,0,255";
  export SUBTITLE_GREY_LEVELS_DESCRIPTION="Defines the grey levels used to distinguish subtitles from the background";
  if [ "${SUBTITLE_GREY_LEVELS+1}" != "1" ]; then
    export SUBTITLE_GREY_LEVELS="${SUBTITLE_GREY_LEVELS_DEFAULT}";
  fi

  export DISABLE_SUBTITLE_PROCESSING_DEFAULT="y";
  export DISABLE_SUBTITLE_PROCESSING_DESCRIPTION="Disables the process of extracting and converting subtitles";
  if [ "${DISABLE_SUBTITLE_PROCESSING+1}" != "1" ]; then
    export DISABLE_SUBTITLE_PROCESSING="${DISABLE_SUBTITLE_PROCESSING_DEFAULT}";
  fi

  ENV_VARIABLES=(\
    DVD_DEVICE \
    AUDIO_LANG \
    SUBTITLE_LANG \
    RIP_EXTRA_LANG \
    VIDEO_WIDTH \
    VIDEO_CODEC \
    CONTENT_TYPE \
    QUALITY \
    VIDEO_OPTS_XVID_LAVC_FIRST_PASS \
    VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS \
    VIDEO_OPTS_MPEG4_FIRST_PASS \
    VIDEO_OPTS_H264_FIRST_PASS \
    AUDIO_OPTS_FIRST_PASS \
    VIDEO_OPTS_XVID_LAVC_SECOND_PASS \
    VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS \
    VIDEO_OPTS_MPEG4_SECOND_PASS \
    VIDEO_OPTS_H264_SECOND_PASS \
    AUDIO_OPTS_SECOND_PASS \
    AUDIO_CHANNELS \
    CROP_DETECTION_START \
    CROP_DETECTION_DURATION \
    DVD_COPY_EXTRA_OPTS \
    DISABLE_EJECT \
    SUBTITLE_GREY_LEVELS \
    DISABLE_SUBTITLE_PROCESSING \
  );
 
  export ENV_VARIABLES;
}

# Error messages
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export MPLAYER_NOT_INSTALLED="mplayer not installed";
  export MENCODER_NOT_INSTALLED="mencoder not installed";
  export LSDVD_NOT_INSTALLED="lsdvd not installed";
  export AVIMERGE_NOT_INSTALLED="avimerge not installed. Install transcode";
  export TCCAT_NOT_INSTALLED="tccat not installed";
  export TCEXTRACT_NOT_INSTALLED="tcextract not installed";
  export SUBTITLE2PGM_NOT_INSTALLED="subtitle2pgm not installed";
  export PGM2TXT_NOT_INSTALLED="pgm2txt not installed";
  export SRTTOOL_NOT_INSTALLED="srttool not installed";
  export ISPELL_NOT_INSTALLED="ispell not installed";
  export DVD_TRACK_OR_INPUT_FILE_ARE_MANDATORY="Either dvd-track or input file are mandatory";
  export INPUT_FILE_DOES_NOT_EXIST="input-file does not exist";
  export OUTPUT_FILE_IS_MANDATORY="output-file is mandatory";
  export OUTPUT_FILE_ALREADY_EXISTS="output-file already exists";
  export CANNOT_WRITE_OUTPUT_FILE="Cannot write output-file";
  export UNSUPPORTED_VIDEO_CODEC="Specified video codec is not supported. ${SCRIPT_NAME} currently supports XviD, mpeg4 and H.264";
  export INVALID_QUALITY="Specified quality is not supported. Use 'lowest', 'low', 'regular', 'good', 'high' or 'highest'";
  export CANNOT_GUESS_CANDIDATE_DVD_TRACK="Could not figure out the candidate track in given DVD";
  export SPECIFIED_AUDIO_UNAVAILABLE="Specified language is not available in source file/DVD";
  export ERROR_IN_FIRST_PASS="Error in first pass. Maybe you'll want to define different AUDIO_OPTS_FIRST_PASS and/or VIDEO_OPTS_FIRST_PASS environment variables";
  export ERROR_IN_SECOND_PASS="Error in second pass. Maybe you'll want to define different AUDIO_OPTS_SECOND_PASS and/or VIDEO_OPTS_SECOND_PASS environment variables";
  export ERROR_RIPPING_EXTRA_AUDIO="Error ripping extra audio";
  export ERROR_MERGING_ADDITIONAL_AUDIO_TRACKS="Error merging additional audio tracks";
  export ERROR_EXTRACTING_ADDITIONAL_SUBTITLES="Error extracting additional subtitles";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    MPLAYER_NOT_INSTALLED \
    MENCODER_NOT_INSTALLED \
    LSDVD_NOT_INSTALLED \
    AVIMERGE_NOT_INSTALLED \
    TCCAT_NOT_INSTALLED \
    TCEXTRACT_NOT_INSTALLED \
    SUBTITLE2PGM_NOT_INSTALLED \
    PGM2TXT_NOT_INSTALLED \
    SRTTOOL_NOT_INSTALLED \
    ISPELL_NOT_INSTALLED \
    DVD_TRACK_OR_INPUT_FILE_ARE_MANDATORY \
    INPUT_FILE_DOES_NOT_EXIST \
    OUTPUT_FILE_IS_MANDATORY \
    OUTPUT_FILE_ALREADY_EXISTS \
    CANNOT_WRITE_OUTPUT_FILE \
    UNSUPPORTED_VIDEO_CODEC \
    INVALID_QUALITY \
    CANNOT_GUESS_CANDIDATE_DVD_TRACK \
    SPECIFIED_AUDIO_UNAVAILABLE \
    ERROR_IN_FIRST_PASS \
    ERROR_IN_SECOND_PASS \
    ERROR_RIPPING_EXTRA_AUDIO \
    ERROR_MERGING_ADDITIONAL_AUDIO_TRACKS \
    ERROR_EXTRACTING_ADDITIONAL_SUBTITLES \
  );

  export ERROR_MESSAGES;
}
 
# Checking input
function checkInput() {
 
  logInfo -n "tput cols";
  logInfoResult SUCCESS "$(tput cols)";

  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;
  logInfo -n "Checking input";

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q)
         shift;
         ;;
      -d | --dry-run)
         DRY_RUN=1;
         shift;
         ;;
      -a | --audio)
         shift;
         AUDIO_ID="${AUDIO_ID} $1";
         shift;
         ;;
      -s | --subtitle)
         shift;
         SUBTITLE_ID="${SUBTITLE_ID} $1";
         shift;
         ;;
      -S | --skip-crop-detection)
         SKIP_CROP_DETECTION=1;
         shift;
         ;;
      *) exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done
 
  # Parameters
  if [ "x${INPUT}" == "x" ]; then
    INPUT="$1";
    shift;
    if [ "${INPUT##dvd:\/\/}" == "${INPUT}" ]; then
      if [ ! -f "${INPUT}" ]; then
        logInfoResult FAILURE "fail";
        exitWithErrorCode INPUT_FILE_DOES_NOT_EXIST;
      fi
    fi
  fi

  if [ "x${INPUT}" == "x" ]; then
    logInfoResult FAILURE "fail";
    exitWithErrorCode DVD_TRACK_OR_INPUT_FILE_ARE_MANDATORY;
  fi
 
  if [ "x${OUTPUT_FILE}" == "x" ]; then
    OUTPUT_FILE="$1";
    shift;
  fi

  if [ "x${OUTPUT_FILE}" == "x" ]; then
    logInfoResult FAILURE "fail";
    exitWithErrorCode OUTPUT_FILE_IS_MANDATORY;
  fi
  
  if [ ! -f "${OUTPUT_FILE}" ]; then
    if [ "x`basename ${OUTPUT_FILE} .avi`" == "x${OUTPUT_FILE}" ]; then
      OUTPUT_FILE="${OUTPUT_FILE}.avi";
    fi
  fi

  if [ -f "${OUTPUT_FILE}" ]; then
    if [ "x${DRY_RUN}" != "x" ]; then
      logInfoResult FAILURE "dry-run";
    else
      logInfoResult FAILURE "fail";
      exitWithErrorCode OUTPUT_FILE_ALREADY_EXISTS;
    fi
  else
    if [ ! -x "`dirname \"${OUTPUT_FILE}\"`" ]; then
      if [ "x${DRY_RUN}" != "x" ]; then
        logInfoResult WARN "fail";
      else
        logInfoResult FAILURE "fail";
        exitWithErrorCode CANNOT_WRITE_OUTPUT_FILE;
      fi
    else
      if [ "x${DRY_RUN}" == "x" ]; then
        logInfoResult SUCCESS "valid";
      fi
    fi
  fi

  if    [ "x`echo ${VIDEO_CODEC} | tr [:upper:] [:lower:]`" != "xxvid" ] \
    &&  [ "x`echo ${VIDEO_CODEC} | tr [:upper:] [:lower:]`" != "xmpeg4" ] \
    &&  [ "x`echo ${VIDEO_CODEC} | tr [:upper:] [:lower:]`" != "xh264" ]; then
     logInfoResult FAILURE "fail";
     exitWithErrorCode UNSUPPORTED_VIDEO_CODEC;
  fi
}

# Finds out the actual audio ids
function retrieve_audio_id_from_audio_lang() {
  local _envVariable="${1}";
  local _audioLang="${2}";
  local _aux;
  local _result;

#  if [ "x${AUDIO_CHANNELS}" != "x" ]; then
#    logInfo -n "Finding out audio id from specified channels, locale preferences or environment explicit ${_envVariable} variable (${_audioLang})";
#    _result=`lsdvd -t ${_track} -a ${DVD_DEVICE} 2> /dev/null | grep "Language: ${_audioLang}" | grep "Channels: ${AUDIO_CHANNELS}" | head -n 1 | cut -d ':' -f 2 | cut -d ',' -f 1 | xargs echo "127+" | bc 2> /dev/null`;
#    if [ "x${_result}" == "x" ]; then
#      logInfoResult FAILURE "unavailable";
#    else
#      logInfoResult SUCCESS "${_result}";
#    fi
#  fi
  if [ "x${_result}" == "x" ]; then
    logInfo -n "Finding out audio id from locale preferences, or explicit ${_envVariable} variable (${_audioLang})";
    _aux=`lsdvd -a ${DVD_DEVICE} 2> /dev/null | grep -C 10 "Title: ${_track}" | grep "Language: ${_audioLang}"`;
    if [ "x${_aux}" != "x" ]; then
      _result=`echo ${_aux} | head -n 1 | cut -d ':' -f 2 | cut -d ',' -f 1 | xargs echo "127+" | bc`;
    fi
    if [ "x${_result}" == "x" ]; then
      logInfoResult WARN "unavailable";
#      exitWithErrorCode SPECIFIED_AUDIO_UNAVAILABLE;
    else
      logInfoResult SUCCESS "${_result}";
    fi
  fi
  export RESULT="${_result}";
}

# Finds out the actual subtitle ids
function retrieve_subtitle_id_from_subtitle_lang() {
  local _track="${1}";
  local _subtitleLang="${2}";
  local _result;

  logInfo -n "Finding out subtitle id for ${_subtitleLang} language";
  _result=`lsdvd -s ${DVD_DEVICE} 2> /dev/null | grep -C 10 "Title: ${_track}" | grep "Language: ${_subtitleLang}" | head -n 1 | cut -d ':' -f 2 | cut -d ',' -f 1 2> /dev/null`;
  if [ "x${_result}" == "x" ]; then
    logInfoResult FAILURE "unavailable";
  else
    logInfoResult SUCCESS "${_result}";
  fi
  export RESULT="${_result}";
}

function retrieve_sub_language() {
  local _track="${1}";
  local _sid="${2}";

  local _result="`lsdvd -s -t ${_track} | grep \"Subtitle: ${_sid}\" | awk '{print $4;}'`";

  export RESULT="${_result}";
}

# Calls mplayer and mencoder to perform a two-phase encoding in xdiv+mp3.
function main() {

  local _dvdDevice="";
  local _slang;

  if [ "x${DVD_DEVICE}" != "x${DVD_DEVICE_DEFAULT}" ]; then
    _dvdDevice="-dvd-device ${DVD_DEVICE}";
  fi

  if    [ "${INPUT##dvd:\/\/}" != "${INPUT}" ] ; then
#     && [ "x${_dvdDevice}" != "x${DVD_DEVICE_DEFAULT}" ] \
#     && [ "${_dvdDevice##dvd:\/\/}" != "${_dvdDevice}" ]; then

    # It's a dvd, let's check if there's actually a track
    # specified or we need to let lsdvd guess it.
    local _track="${INPUT##dvd:\/\/}";
    if [ "x${_track}" == "x" ]; then
      logInfo -n "Finding out longest track since none was specified";
      _track=`lsdvd ${DVD_DEVICE} 2> /dev/null | tail -n 2 | head -n 1 | cut -d ':' -f 2 | tr -d '[:space:]'`;
      if [ "x${_track}" == "x" ]; then
        logInfoResult FAILURE "fail";
        exitWithErrorCode CANNOT_GUESS_CANDIDATE_DVD_TRACK;
      else
        logInfoResult SUCCESS "${_track}";
        INPUT="dvd://${_track}";
      fi
    fi
    _track=${_track##0};
    if [ $((_track)) -lt 10 ]; then
      _track="0${_track}";
    fi

    if [ "x${AUDIO_ID## }" == "x" ]; then
      retrieve_audio_id_from_audio_lang "AUDIO_LANG" "${AUDIO_LANG}";
      AUDIO_ID="${RESULT}";
      if    [ "x${RIP_EXTRA_LANG}" != "x" ] \
         && [ "x${RIP_EXTRA_LANG}" != "x${AUDIO_LANG}" ]; then
        retrieve_audio_id_from_audio_lang "RIP_EXTRA_LANG" "${RIP_EXTRA_LANG}";
        if [ "x${RESULT}" != "x${AUDIO_ID}" ]; then
          AUDIO_ID="${AUDIO_ID} ${RESULT}";
        fi
      fi
    fi

    if [ "x${DISABLE_SUBTITLE_PROCESSING}" == "x" ]; then
      if [ "x${SUBTITLE_ID## }" == "x" ]; then
        retrieve_subtitle_id_from_subtitle_lang ${_track} "${SUBTITLE_LANG}";
        SUBTITLE_ID="${RESULT}";
        _subtitleLangs="${SUBTITLE_LANG}";
        if [ "x${RIP_EXTRA_LANG}" != "x" ]; then
          retrieve_subtitle_id_from_subtitle_lang ${_track} "${RIP_EXTRA_LANG}";
          if [ "x${RESULT}" != "x${SUBTITILE_ID}" ]; then
            SUBTITLE_ID="${SUBTITLE_ID} ${RESULT}";
            _subtitleLangs="${_subtitleLangs} ${RIP_EXTRA_LANG}";
          fi
        fi
      fi
    fi

    local new_input="${OUTPUT_FILE%.*}.vob";
    if [ -f ${new_input} ]; then
      logInfo "Using already existing ${new_input}";
    else
      if [ "x${DRY_RUN}" != "x" ]; then
        logInfo mplayer ${DVD_COPY_EXTRA_OPTS} -dumpstream -dumpfile ${new_input} ${INPUT};
      else
        logInfo -n "Copying ${INPUT} to ${new_input}";
        runCommandLongOutput \
          mplayer ${_dvdDevice} ${DVD_COPY_EXTRA_OPTS} -dumpstream -dumpfile ${new_input} ${INPUT};
        logInfoResult SUCCESS "done";
      fi
    fi

    local _squote="'";
    if [ "x${DISABLE_SUBTITLE_PROCESSING}" == "x" ]; then
      for s in `echo ${SUBTITLE_ID} | sed 's| |\n|g' | sort | uniq`; do
        retrieve_sub_language ${_track} ${s};
        _slang="${RESULT}";
        if    [ "x${_slang}" != "xen" ] \
           && [ "x${_slang}" != "xfr" ] \
           && [ "x${_slang}" != "xde" ]; then
          logInfo -n "Skipping subtitle extraction for ${_squote}${_slang}${_squote} since it${_squote}s not supported by pgm2txt";
          logInfoResult FAILURE "skip";
        else
          if isLowerThanInfoEnabled; then
            logDebug -n "Extracting ${_squote}${_slang}${_squote} (${s}) subtitle stream";
          else
            logInfo -n "Extracting ${_squote}${_slang}${_squote} subtitle (${s}) to ${OUTPUT_FILE}-${_slang}.srt";
          fi
          if [ "x${DRY_RUN}" != "x" ]; then
            if isLowerThanInfoEnabled; then
              logDebugResult SUCCESS "done"
            else
              logInfoResult SUCCESS "dry-run"
            fi
            logInfo "tccat -i ${DVD_DEVICE} -T ${_track#0},-1 | tcextract -x ps1 -t vob -a 0x$((20+$s)) > ${OUTPUT_FILE}-${_slang}.ps1"
          else
            tccat -i ${DVD_DEVICE} -T ${_track#0},-1 | tcextract -x ps1 -t vob -a 0x$((20+$s)) > ${OUTPUT_FILE}-${_slang}.ps1 
          fi
          if [ $? == 0 ]; then
            if isLowerThanInfoEnabled; then
              if [ "x${DRY_RUN}" == "x" ]; then
                logDebugResult SUCCESS "done"
              fi
              logDebug -n "Converting ${_squote}${_slang}${_squote} subtitle (${s}) to image sequence";
            fi
            if [ "x${DRY_RUN}" != "x" ]; then
              if isLowerThanInfoEnabled; then
                logDebugResult SUCCESS "dry-run"
              fi
              logInfo "subtitle2pgm -o ${OUTPUT_FILE}-${_slang} -c ${SUBTITLE_GREY_LEVELS} < ${OUTPUT_FILE}-${_slang}.ps1";
            else
              subtitle2pgm -o ${OUTPUT_FILE}-${_slang} -c ${SUBTITLE_GREY_LEVELS} < ${OUTPUT_FILE}-${_slang}.ps1;
            fi
            if [ $? == 0 ]; then
              if isLowerThanInfoEnabled; then
                if [ "x${DRY_RUN}" == "x" ]; then
                  logDebugResult SUCCESS "done"
                fi
                logDebug -n "Converting images to text via OCR for ${_squote}${_slang}${_squote} subtitle (${s})";
              fi
              if [ "x${DRY_RUN}" != "x" ]; then
                if isLowerThanInfoEnabled; then
                  logDebugResult SUCCESS "dry-run"
                fi
                logInfo "pgm2txt -f ${_slang} ${OUTPUT_FILE}-${s}";
              else
                pgm2txt -f ${_slang} ${OUTPUT_FILE}-${s};
              fi
              if [ $? == 0 ]; then
                if isLowerThanInfoEnabled; then
                  if [ "x${DRY_RUN}" == "x" ]; then
                    logDebugResult SUCCESS "done"
                  fi
                  logDebug -n "Spell-checking subtitles";
                fi
                if [ "x${DRY_RUN}" != "x" ]; then
                  if isLowerThanInfoEnabled; then
                    logDebugResult SUCCESS "dry-run"
                  fi
                  logInfo "ispell -d american ${OUTPUT_FILE}-${s}";
                else
                  if [ "x${_slang}" == "xen" ]; then
                    ispell -d american ${OUTPUT_FILE}-${s};
                  else
                    echo -n;
                  fi
                fi
                if [ $? == 0 ]; then
                  if [ "x${DRY_RUN}" != "x" ]; then
                    if isLowerThanInfoEnabled; then
                      logDebugResult SUCCESS "dry-run"
                    fi
                    logInfo "srttool -s -w < ${OUTPUT_FILE}-${s}.srtx > ${OUTPUT_FILE}.${_slang}.srt";
                  else
                    srttool -s -w < ${OUTPUT_FILE}-${s}.srtx > ${OUTPUT_FILE}.${_slang}.srt \
                      && rm -f ${OUTPUT_FILE}.${_slang}.{srtx,ps1} 2> /dev/null;
                  fi
                  if [ $? == 0 ]; then
                    if isLowerThanInfoEnabled; then
                      if [ "x${DRY_RUN}" == "x" ]; then
                        logDebugResult SUCCESS "done"
                      fi
                    else
                      logInfoResult SUCCESS "done"
                    fi
                  else
                    if isLowerThanInfoEnabled; then
                      logDebugResult FAILURE "failed"
                    else
                      logInfoResult FAILURE "failed"
                    fi
                  fi
                else
                  if isLowerThanInfoEnabled; then
                    logDebugResult FAILURE "failed"
                  else
                    logInfoResult FAILURE "failed"
                  fi
                fi
              else
                if isLowerThanInfoEnabled; then
                  logDebugResult FAILURE "failed"
                else
                  logInfoResult FAILURE "failed"
                fi
              fi
            else
              if isLowerThanInfoEnabled; then
                logDebugResult FAILURE "failed"
              else
                logInfoResult FAILURE "failed"
              fi
            fi
          else
            if isLowerThanInfoEnabled; then
              logDebugResult FAILURE "failed"
            else
              logInfoResult FAILURE "failed"
            fi
          fi
        fi
        rm -f ${OUTPUT_FILE}-${_slang}*.{pgm,srtx,ps1} 2> /dev/null
      done;
    fi

    if [ "x${DISABLE_EJECT}" == "x" ]; then
      logInfo -n "Ejecting DVD since it's not longer needed (background)"
          
      if [ "x${DRY_RUN}" != "x" ]; then
        logInfoResult SUCCESS "dry-run";
        logInfo -n "eject $DVD_DEVICE";
      else
        eject $DVD_DEVICE 2> /dev/null &
      fi
      if [ $? == 0 ]; then
        logInfoResult SUCCESS "done"
      else
        logInfoResult FAILURE "failed"
      fi
    fi

    INPUT="${new_input}";
  fi

  local _audioChannels;

  if [ "x${AUDIO_CHANNELS}" != "x" ]; then
    _audioChannels="-channels ${AUDIO_CHANNELS}";
  fi

  local _twoPassFile="`dirname \"{OUTPUT_FILE}\"`/${OUTPUT_FILE}.log";

  if [ "x${SKIP_CROP_DETECTION}" == "x" ]; then

    runCommandLongOutput \
      mplayer \
        ${_dvdDevice} -ss ${CROP_DETECTION_START} -endpos ${CROP_DETECTION_DURATION} -vf cropdetect \
        "${INPUT}";
    local _resultCode=$?;
    logInfo -n "Detecting crop window...";
    local _cropOpts=`grep "\[CROP\]" "${RESULT}" 2> /dev/null | tail -n 1 | sed 's/.*(\(.*\)).*/\1/g'`;
    if [ ${_resultCode} == 0 ]; then
      local _fields=`echo "${_cropOpts##*=}" | awk -F":" '{print NF;}'`;
      if [ "${_fields}" == "4" ]; then
        logInfoResult SUCCESS "${_cropOpts##*=}";
      else
        _cropOpts="";
        logInfoResult FAILURE "failed";
      fi
    else
      _cropOpts="";
      logInfoResult FAILURE "failed";
    fi
  fi

  local _aid;
  local _defaultAid;
  if [ "x${AUDIO_ID}" != "x" ]; then
    _defaultAid="`echo ${AUDIO_ID} | cut -d ' ' -f 1`";
    _aid="-aid ${_defaultAid}";
  fi

  local _alang="";
  if [ "x${AUDIO_LANG}" != "x" ]; then
    _alang="-alang ${AUDIO_LANG}";
  fi

  local _sid;
  local _sfile;
  local _defaultSid;
  local _defaultSLang;
  if [ "x${SUBTITLE_ID}" != "x" ]; then
    _defaultSid="`echo ${SUBTITLE_ID} | cut -d ' ' -f 1`";
    _defaultSLang="`echo ${_subtitleLangs} | cut -d ' ' -f 1`";
    _sid="-vobsubout `basename ${OUTPUT_FILE} .avi`.${_defaultSLang}.sub -vobsuboutindex 0 -sid ${_defaultSid}";
  fi

  local _videoOptsFirstPass="${VIDEO_OPTS_FIRST_PASS}";

  if [ -f ${_twoPassFile} ]; then
    logInfo -n "First pass...";
    logInfoResult SUCCESS "already done";
  else
    if isLowerThanInfoEnabled; then
      logInfo "First pass...";
    else
      logInfo -n "First pass...";
    fi

    if [ "x${DRY_RUN}" != "x" ]; then
      logInfo \
        mencoder "${INPUT}" \
        -passlogfile ${_twoPassFile} \
        ${_dvdDevice} \
        ${_videoOptsFirstPass} \
        ${AUDIO_OPTS_FIRST_PASS} \
        ${_cropOpts} \
        ${_audioChannels} \
        ${_alang} \
        -o /dev/null;
    else
      runCommandLongOutput \
        mencoder "${INPUT}" \
        -passlogfile ${_twoPassFile} \
        ${_dvdDevice} \
        ${_videoOptsFirstPass} \
        ${AUDIO_OPTS_FIRST_PASS} \
        ${_cropOpts} \
        ${_audioChannels} \
        ${_alang} \
        -o /dev/null;
    fi
    if [ $? == 0 ]; then
      if [ isLowerThanInfoEnabled ]; then
        logInfoResult SUCCESS "done";
      fi
    else
      if [ isLowerThanInfoEnabled ]; then
        logInfoResult FAILURE "fail";
      fi
      logDebugFileContents "${RESULT}";
      exitWithErrorCode ERROR_IN_FIRST_PASS;
      rm -f "${_twoPassFile}"
    fi
  fi
# if [ ! -f "${OUTPUT_FILE}" ]; then

  if isLowerThanInfoEnabled; then
    logInfo "Second pass...";
  else
    logInfo -n "Second pass...";
  fi

  local _videoOptsSecondPass="${VIDEO_OPTS_SECOND_PASS}";
  if [ "x${DRY_RUN}" != "x" ]; then
    logInfo \
      mencoder "${INPUT}" \
      -passlogfile ${_twoPassFile} \
      ${_dvdDevice} \
      ${_videoOptsSecondPass} \
      ${AUDIO_OPTS_SECOND_PASS} \
      ${_cropOpts} \
      ${_audioChannels} \
      ${_alang} \
      ${_aid} \
      -o "$OUTPUT_FILE";
#      ${_sid} \
  else
    runCommandLongOutput \
      mencoder "${INPUT}" \
      -passlogfile ${_twoPassFile} \
      ${_dvdDevice} \
      ${_videoOptsSecondPass} \
      ${AUDIO_OPTS_SECOND_PASS} \
      ${_cropOpts} \
      ${_audioChannels} \
      ${_alang} \
      ${_aid} \
      -o "$OUTPUT_FILE";
#      ${_sid} \
  fi
  if [ $? == 0 ]; then
    if isLowerThanInfoEnabled; then
      logInfoResult SUCCESS "done";
    fi
  else
    if isLowerThanInfoEnabled; then
      logInfoResult FAILURE "fail";
    fi
    logDebugFileContents "${RESULT}";
    exitWithErrorCode ERROR_IN_SECOND_PASS;
  fi
#fi

  local _totalAids=`echo ${AUDIO_ID} | awk '{print NF}'`;
  local _index;
  if [ ${_totalAids} -gt 1 ]; then
    _index=2;
    while [ ${_index} -le ${_totalAids} ]; do
      _aid="-aid `echo ${AUDIO_ID} | awk -v i=${_index} '{print $i;}'`";
      _slang="`echo ${_subtitleLangs} | awk -v i=${_index} '{print $i;}'`";
      if [ "x${_slang}" == "x" ]; then
        _slang="en";
      fi
      _afile="`basename ${OUTPUT_FILE} .avi`.${_slang}";
      _sfile="${_afile}.sub";
      _sid="-vobsubout ${_sfile} -vobsuboutindex 1 -sid `echo ${SUBTITLE_ID} | awk -v i=${_index} '{print $i;}'`";
      _index=$((_index+1));

      if [ "x${DRY_RUN}" != "x" ]; then

        logInfo \
          mencoder "${INPUT}" \
          -passlogfile ${_twoPassFile} \
          ${_dvdDevice} \
          -ovc frameno \
          ${AUDIO_OPTS_SECOND_PASS} \
          ${_aid} \
          -o ${_afile}.avi;
#          ${_sid} \
      else
        if [ -f ${_afile}.avi ]; then
          logInfo "Using already existing ${_afile}.avi";
          logInfoResult SUCCESS "skip";
        else
          if isLowerThanInfoEnabled; then
            logInfo "Ripping additional audio/subtitiles...";
          else
            logInfo -n "Ripping additional audio/subtitiles...";
          fi

#        echo "${_index}/total aids: ${_totalAids} : ${AUDIO_ID} ${_defaultAid}"
#        if [ ${_index} -gt 5 ]; then exit; fi;

#        echo \
          runCommandLongOutput \
            mencoder "${INPUT}" \
            -passlogfile ${_twoPassFile} \
            ${_dvdDevice} \
            -ovc frameno \
            ${AUDIO_OPTS_SECOND_PASS} \
            ${_aid} \
            -o ${_afile}.avi;
#            ${_sid} \
          if [ $? == 0 ]; then
            if isLowerThanInfoEnabled; then
              logInfoResult SUCCESS "done";
            fi
          else
            if isLowerThanInfoEnabled; then
              logInfoResult FAILURE "fail";
            fi
            logDebugFileContents "${RESULT}";
            exitWithErrorCode ERROR_RIPPING_EXTRA_AUDIO;
          fi
        fi
      fi

      if [ "x${DRY_RUN}" != "x" ]; then

        logInfo \
          avimerge \
          -i "${OUTPUT_FILE}" \
          -o "${OUTPUT_FILE}.in-progress" \
          -p "${_afile}.avi";
        logInfo mv "${OUTPUT_FILE}.in-progress" "${OUTPUT_FILE}";

      else

        if isLowerThanInfoEnabled; then
          logInfo "Merging audio track into existing video...";
        else
          logInfo -n "Merging audio track into existing video...";
        fi

        runCommandLongOutput \
          avimerge \
          -i "${OUTPUT_FILE}" \
          -o "${OUTPUT_FILE}.in-progress" \
          -p "${_afile}.avi" \
        && mv "${OUTPUT_FILE}.in-progress" "${OUTPUT_FILE}";

        if [ $? == 0 ]; then
          if isLowerThanInfoEnabled; then
            logInfoResult SUCCESS "done";
          fi
        else
          if isLowerThanInfoEnabled; then
            logInfoResult FAILURE "fail";
          fi
          logDebugFileContents "${RESULT}";
          exitWithErrorCode ERROR_MERGING_ADDITIONAL_AUDIO_TRACKS;
        fi
      fi
    done
  fi
  logInfo "Finished ripping ${INPUT} to ${OUTPUT_FILE}";
}

function deprecated_extract_subs() {
  local _totalSubs=`echo ${SUBTITLE_ID} | awk '{print NF;}'`;
  if [ ${_totalSubs} -gt 1 ]; then
    _aid="-aid ${_defaultAid}";
    _sid="fake";
    _index=1;
    _slang="`echo ${_subtitleLangs} | awk -v i=${_index} '{print $i;}'`";
    _afile="`basename ${OUTPUT_FILE} .avi`.${_slang}";
    _sfile="${_afile}.sub";
    _sid="`echo ${SUBTITLE_ID} | awk -v i=${_index} '{print $i;}'`";
    if [ "x${_sid}" != "" ]; then
      _sid="-sid ${_sid}";
      _index=$((_index+1));

      if [ "x${DRY_RUN}" != "x" ]; then

        logInfo \
          mencoder "${INPUT}" \
          -passlogfile ${_twoPassFile} \
          ${_dvdDevice} \
          -ovc frameno \
          ${_aid} \
          ${_sid} \
          -vobsubout ${_sfile} -vobsuboutindex 1 \
          -o /dev/null;

      else
        if isLowerThanInfoEnabled; then
          logInfo "Extracting subtitles for default language...";
        else
          logInfo -n "Extracting subtitles for default language...";
        fi

#        echo \
        runCommandLongOutput \
          mencoder "${INPUT}" \
          -passlogfile ${_twoPassFile} \
          ${_dvdDevice} \
          -ovc frameno \
          -nosound
          ${_aid} \
          ${_sid} \
          -vobsubout ${_sfile} -vobsuboutindex 1 \
          -o /dev/null;

        if [ $? == 0 ]; then
          if isLowerThanInfoEnabled; then
            logInfoResult SUCCESS "done";
          fi
        else
          if isLowerThanInfoEnabled; then
            logInfoResult FAILURE "fail";
          fi
          logDebugFileContents "${RESULT}";
          exitWithErrorCode ERROR_EXTRACTING_ADDITIONAL_SUBTITLES;
        fi
      fi

      if [ "x${DRY_RUN}" != "x" ]; then
        logInfo sub2srt "${_sfile}" "`basename ${_sfile} .sub`.srt";
      else
        if isLowerThanInfoEnabled; then
          logInfo "Converting ${_sfile} to `basename ${_sfile} .sub`.srt...";
        else
          logInfo -n "Converting ${_sfile} to `basename ${_sfile} .sub`.srt...";
        fi

        sub2srt "${_sfile}" "`basename ${_sfile} .sub`.srt";
        if [ $? == 0 ]; then
          if isLowerThanInfoEnabled; then
            logInfoResult SUCCESS "done";
          fi
          rm -f "${_sfile}";
        else
          if isLowerThanInfoEnabled; then
            logInfoResult FAILURE "fail";
          fi
#          exitWithErrorCode ERROR_CONVERTING_SUBTITLES;
        fi
      fi
    fi
  fi
}

