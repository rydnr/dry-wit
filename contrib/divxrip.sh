#!/bin/bash dry-wit
# Copyright 2009-today Automated Computing Machinery S.L.
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
  checkReq ${MPLAYER_COMMAND} MPLAYER_NOT_INSTALLED;
  checkReq mencoder MENCODER_NOT_INSTALLED;
  checkReq lsdvd LSDVD_NOT_INSTALLED;
  checkReq avimerge AVIMERGE_NOT_INSTALLED;
  checkReq tccat TCCAT_NOT_INSTALLED;
  checkReq tcextract TCEXTRACT_NOT_INSTALLED;
  checkReq subtitle2pgm SUBTITLE2PGM_NOT_INSTALLED;
  checkReq pgm2txt PGM2TXT_NOT_INSTALLED;
  checkReq srttool SRTTOOL_NOT_INSTALLED;
  checkReq ispell ISPELL_NOT_INSTALLED;
  checkReq bc BC_NOT_INSTALLED;
  if [ "x$(echo CONTAINER_FORMAT 2> /dev/null| tr '[:lower:]' '[:upper:]' 2> /dev/null)" == "xMKV" ]; then
    checkReq bitrate BITRATE_NOT_INSTALLED;
    checkReq dvdxchap DVDXCHAP_NOT_INSTALLED;
    checkReq transcode TRANSCODE_NOT_INSTALLED;
    checkReq subtitleripper SUBTITLERIPPER_NOT_INSTALLED;
    checkReq mkvmerge MKVMERGE_NOT_INSTALLED;
  fi
}
 
# Environment
function defineEnv() {
  export MPLAYER_COMMAND_DEFAULT="$(which mplayer 2> /dev/null)";
  export MPLAYER_COMMAND_DESCRIPTION="The mplayer executable";
  if    [ "${MPLAYER_COMMAND+1}" != "1" ] \
     || [ "x${MPLAYER_COMMAND}" == "x" ]; then
    export MPLAYER_COMMAND="${MPLAYER_COMMAND_DEFAULT}";
  fi

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

  export AUDIO_LANG_DEFAULT="$(echo $LANG | cut -d '_' -f 1)";
  export AUDIO_LANG_DESCRIPTION="The audio language (in two-digits ISO format: en, es, fr...)";
  if [ "${AUDIO_LANG+1}" != "1" ]; then
    export AUDIO_LANG="${AUDIO_LANG_DEFAULT}";
  fi
  
  export SUBTITLE_LANG_DEFAULT="$(echo $LANG | cut -d '_' -f 1)";
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

  export VIDEO_CODEC_DEFAULT="xvid";
  export VIDEO_CODEC_DESCRIPTION="The video codec to use";
  if    [ "${VIDEO_CODEC+1}" != "1" ] \
     || [ "x${VIDEO_CODEC}" == "x" ]; then
    export VIDEO_CODEC="${VIDEO_CODEC_DEFAULT}";
  fi

  export CONTAINER_FORMAT_DEFAULT="mkv";
  export CONTAINER_FORMAT_DESCRIPTION="The container, either avi or mkv";
  if    [ "${CONTAINER_FORMAT+1}" != "1" ] \
     || [ "x${CONTAINER_FORMAT}" == "x" ]; then
    export CONTAINER_FORMAT="${CONTAINER_FORMAT_DEFAULT}";
  fi

  export MKV_TARGET_SIZE_DEFAULT="2440";
  export MKV_TARGET_SIZE_DESCRIPTION="The size of the Matroska output file";
  if    [ "${MKV_TARGET_SIZE+1}" != "1" ] \
     || [ "x${MKV_TARGET_SIZE}" == "x" ]; then
    export MKV_TARGET_SIZE="${MKV_TARGET_SIZE_DEFAULT}";
  fi

  case ${QUALITY} in
    "lowest") export DEFAULT_BITRATE="${LOWEST_QUALITY}";
              ;;
    "low") export DEFAULT_BITRATE="${LOW_QUALITY}";
           ;;
    "regular") export DEFAULT_BITRATE="${REGULAR_QUALITY}";
               ;;
    "good") export DEFAULT_BITRATE="${GOOD_QUALITY}";
            ;;
    "high") export DEFAULT_BITRATE="${HIGH_QUALITY}";
            ;;
    "highest") export DEFAULT_BITRATE="${HIGHEST_QUALITY}";
               ;;
    *) exitWithErrorCode INVALID_QUALITY;
       ;;
  esac

  export VIDEO_WIDTH_DEFAULT="";
  export VIDEO_WIDTH_DESCRIPTION="The width of the output video file"
  if [ "${VIDEO_WIDTH+1}" != "1" ]; then
    export VIDEO_WIDTH="${VIDEO_WIDTH_DEFAULT}";
  fi

  #export COMMON_VIDEO_OPTS_FIRST_PASS_DEFAULT="-forceidx -vf pp,harddup,crop=\${CROP} -ni";
  export COMMON_VIDEO_OPTS_FIRST_PASS_DEFAULT="-forceidx -vf pullup,harddup,softskip,crop=\${CROP} -ni -nosub";
  export COMMON_VIDEO_OPTS_FIRST_PASS_DESCRIPTION="The video options for the first pass, common for all coding schemes";
  if [ "${COMMON_VIDEO_OPTS_FIRST_PASS+1}" != "1" ]; then
    export COMMON_VIDEO_OPTS_FIRST_PASS="${COMMON_VIDEO_OPTS_FIRST_PASS_DEFAULT}";
  fi

#  export VIDEO_OPTS_MPEG4_FIRST_PASS_DEFAULT="-ovc lavc -lavcopts vcodec=mpeg4:vbitrate=${DEFAULT_BITRATE}:vhq:vpass=1:vqmin=1:vqmax=31 -vf scale -zoom -xy ${VIDEO_WIDTH} -vf pp,scale";
  export VIDEO_OPTS_MPEG4_FIRST_PASS_DEFAULT="${COMMON_VIDEO_OPTS_FIRST_PASS} -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=${DEFAULT_BITRATE}:vhq:vpass=1:vqmin=1:vqmax=31";
  export VIDEO_OPTS_MPEG4_FIRST_PASS_DESCRIPTION="The video options for the first pass, for mpeg4 encoding";
  if [ "${VIDEO_OPTS_MPEG4_FIRST_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_MPEG4_FIRST_PASS="${VIDEO_OPTS_MPEG4_FIRST_PASS_DEFAULT}";
  fi

  export VIDEO_OPTS_XVID_LAVC_FIRST_PASS_DEFAULT="${VIDEO_OPTS_MPEG4_FIRST_PASS} -ffourcc XVID";
  export VIDEO_OPTS_XVID_LAVC_FIRST_PASS_DESCRIPTION="The video options for the first pass, for XviD encoding";
  if [ "${VIDEO_OPTS_XVID_LAVC_FIRST_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_XVID_LAVC_FIRST_PASS="${VIDEO_OPTS_XVID_LAVC_FIRST_PASS_DEFAULT}";
  fi

  export VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS_DEFAULT="${COMMON_VIDEO_OPTS_FIRST_PASS} -ovc xvid -xvidencopts pass=1:turbo=2:bitrate=${DEFAULT_BITRATE}:autoaspect:threads=2";
  export VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS_DESCRIPTION="The video options for the second pass, for XviD encoding, using xvidenc";
  if [ "${VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS="${VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS_DEFAULT}";
  fi

#  export VIDEO_OPTS_H264_FIRST_PASS_DEFAULT="${COMMON_VIDEO_OPTS_FIRST_PASS} -ovc x264 -x264encopts threads=auto:partitions=all:subq=5:8x8dct:frameref=2:bframes=3:b_pyramid:weight_b:pass=1:turbo=2:bitrate=\${BITRATE} -ffourcc h264";
  export VIDEO_OPTS_H264_FIRST_PASS_DEFAULT="-nosub -vf pullup,softskip,crop=\${CROP},harddup -ovc x264 -x264encopts bitrate=\${BITRATE}:subq=5:bframes=3:b_pyramid=normal:weight_b:turbo=1:threads=auto:pass=1";
  export VIDEO_OPTS_H264_FIRST_PASS_DESCRIPTION="The video options for the first pass, for H.264 encoding";
  if [ "${VIDEO_OPTS_H264_FIRST_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_H264_FIRST_PASS="${VIDEO_OPTS_H264_FIRST_PASS_DEFAULT}";
  fi

  export AUDIO_OPTS_FIRST_PASS_DEFAULT="-nosound";
  export AUDIO_OPTS_FIRST_PASS_DESCRIPTION="The audio options for the first pass" 
  if [ "${AUDIO_OPTS_FIRST_PASS+1}" != "1" ]; then
    export AUDIO_OPTS_FIRST_PASS="${AUDIO_OPTS_FIRST_PASS_DEFAULT}";
  fi

  export COMMON_VIDEO_OPTS_SECOND_PASS_DEFAULT="${COMMON_VIDEO_OPTS_FIRST_PASS}";
  export COMMON_VIDEO_OPTS_SECOND_PASS_DESCRIPTION="The video options for the second pass, common for all coding schemes";
  if [ "${COMMON_VIDEO_OPTS_SECOND_PASS+1}" != "1" ]; then
    export COMMON_VIDEO_OPTS_SECOND_PASS="${COMMON_VIDEO_OPTS_SECOND_PASS_DEFAULT}";
  fi

#  export VIDEO_OPTS_MPEG4_SECOND_PASS_DEFAULT="-ovc lavc -lavcopts vcodec=mpeg4:vbitrate=\${BITRATE}:vhq:vpass=2:vqmin=1:vqmax=31 -vf scale -zoom -xy ${VIDEO_WIDTH} -vf pp,scale -forceidx";
  export VIDEO_OPTS_MPEG4_SECOND_PASS_DEFAULT="${COMMON_VIDEO_OPTS_SECOND_PASS} -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=\${BITRATE}:vhq:vpass=2:vqmin=1:vqmax=31";
  export VIDEO_OPTS_MPEG4_SECOND_PASS_DESCRIPTION="The video options for the second pass, for mpeg4 encoding";
  if [ "${VIDEO_OPTS_MPEG4_SECOND_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_MPEG4_SECOND_PASS="${VIDEO_OPTS_MPEG4_SECOND_PASS_DEFAULT}";
  fi

  export VIDEO_OPTS_XVID_LAVC_SECOND_PASS_DEFAULT="${VIDEO_OPTS_MPEG4_SECOND_PASS} -ffourcc XVID";
  export VIDEO_OPTS_XVID_LAVC_SECOND_PASS_DESCRIPTION="The video options for the second pass, for XviD encoding, using lavc";
  if [ "${VIDEO_OPTS_XVID_LAVC_SECOND_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_XVID_LAVC_SECOND_PASS="${VIDEO_OPTS_XVID_LAVC_SECOND_PASS_DEFAULT}";
  fi

  export VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS_DEFAULT="${COMMON_VIDEO_OPTS_SECOND_PASS} -ovc xvid -xvidencopts pass=2:turbo=2:bitrate=\${BITRATE}:autoaspect:threads=2";
  export VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS_DESCRIPTION="The video options for the second pass, for XviD encoding, using xvidenc";
  if [ "${VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS="${VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS_DEFAULT}";
  fi

#  export VIDEO_OPTS_H264_SECOND_PASS_DEFAULT="${COMMON_VIDEO_OPTS_SECOND_PASS} -ovc x264 -x264encopts subq=5:8x8dct:frameref=2:bframes=3:b_pyramid:weight_b:pass=2:bitrate=\${BITRATE} -ffourcc h264";
  export VIDEO_OPTS_H264_SECOND_PASS_DEFAULT="${COMMON_VIDEO_OPTS_SECOND_PASS} -ovc x264 -x264encopts subq=5:8x8dct:frameref=2:bframes=3:b_pyramid=normal:weight_b:threads=auto:pass=2:bitrate=\${BITRATE} -ffourcc h264";
  export VIDEO_OPTS_H264_SECOND_PASS_DESCRIPTION="The video options for the second pass, for XviD encoding";
  if [ "${VIDEO_OPTS_H264_SECOND_PASS+1}" != "1" ]; then
    export VIDEO_OPTS_H264_SECOND_PASS="${VIDEO_OPTS_H264_SECOND_PASS_DEFAULT}";
  fi

  case "$(echo ${VIDEO_CODEC}-${CONTENT_TYPE} | tr [:upper:] [:lower:])" in
    "xvid-movie") export VIDEO_OPTS_FIRST_PASS="${VIDEO_OPTS_XVID_LAVC_FIRST_PASS_DEFAULT}";
                  export VIDEO_OPTS_SECOND_PASS="${VIDEO_OPTS_XVID_LAVC_SECOND_PASS_DEFAULT}";
                  ;;
    "xvid-cartoon") export VIDEO_OPTS_FIRST_PASS="$(echo ${VIDEO_OPTS_XVID_XVIDENC_FIRST_PASS_DEFAULT} | sed 's_opts _opts cartoon:_g')";
                    export VIDEO_OPTS_SECOND_PASS="$(echo ${VIDEO_OPTS_XVID_XVIDENC_SECOND_PASS_DEFAULT} | sed 's_opts _opts cartoon:_g')";
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

  export ISPELL_HASH_FOLDER_DEFAULT="/usr/lib64/ispell";
  export ISPELL_HASH_FOLDER_DESCRIPTION="The location of the ispell hash files for each language";
  if [ "${ISPELL_HASH_FOLDER+1}" != "1" ]; then
    export ISPELL_HASH_FOLDER="${ISPELL_HASH_FOLDER_DEFAULT}";
  fi

  export ISPELL_HASH_FILE_SUFFIX_DEFAULT=".hash";
  export ISPELL_HASH_FILE_SUFFIX_DESCRIPTION="The suffix of the ispell hash files under ${ISPELL_HASH_FOLDER}";
  if [ "${ISPELL_HASH_FILE_SUFFIX+1}" != "1" ]; then
    export ISPELL_HASH_FILE_SUFFIX="${ISPELL_HASH_FILE_SUFFIX}";
  fi

  ENV_VARIABLES=(\
    MPLAYER_COMMAND \
    DVD_DEVICE \
    AUDIO_LANG \
    SUBTITLE_LANG \
    RIP_EXTRA_LANG \
    VIDEO_WIDTH \
    VIDEO_CODEC \
    CONTENT_TYPE \
    QUALITY \
    CONTAINER_FORMAT \
    MKV_TARGET_SIZE \
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
    ISPELL_HASH_FOLDER \
    ISPELL_HASH_FILE_SUFFIX \
  );
 
  export ENV_VARIABLES;
}

# Error messages
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export MPLAYER_NOT_INSTALLED="mplayer not installed";
  export MENCODER_NOT_INSTALLED="mencoder not installed";
  export LSDVD_NOT_INSTALLED="lsdvd not installed";
  export AVIMERGE_NOT_INSTALLED="avimerge not installed. Install transcode package";
  export TCCAT_NOT_INSTALLED="tccat not installed";
  export TCEXTRACT_NOT_INSTALLED="tcextract not installed";
  export SUBTITLE2PGM_NOT_INSTALLED="subtitle2pgm not installed. Install subtitleripper package";
  export PGM2TXT_NOT_INSTALLED="pgm2txt not installed";
  export SRTTOOL_NOT_INSTALLED="srttool not installed";
  export ISPELL_NOT_INSTALLED="ispell not installed";
  export BC_NOT_INSTALLED="bc not installed";
  export DVDXCHAP_NOT_INSTALLED="dvdxchap not installed. Install ogmtools package";
  export TRANSCODE_NOT_INSTALLED="transcode not installed. Install transcode package";
  export SUBTITLERIPPER_NOT_INSTALLED="subtitleripper not installed. Install subtitleripper package";
  export MKVMERGE_NOT_INSTALLED="mkvmerge not installed. Install mkvtoolnix";
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
  export UNSUPPORTED_CONTAINER_FORMAT="Unsupported container format. Can only encode in mkv or avi";
  export ERROR_CREATING_MKV_FILE="Error creating mkv file";

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
    BC_NOT_INSTALLED \
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
    UNSUPPORTED_CONTAINER_FORMAT \
    ERROR_CREATING_MKV_FILE \
  );

  export ERROR_MESSAGES;
}
 
# Checking input
function checkInput() {
 
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
    if [ "x$(basename ${OUTPUT_FILE} .avi)" == "x${OUTPUT_FILE}" ]; then
      OUTPUT_FILE="${OUTPUT_FILE}.avi";
    fi
  fi

  if [ -f "${OUTPUT_FILE}" ]; then
    if is_dry_run; then
      logInfoResult FAILURE "dry-run";
    else
      logInfoResult FAILURE "fail";
      exitWithErrorCode OUTPUT_FILE_ALREADY_EXISTS;
    fi
  else
    if [ ! -x "$(dirname "${OUTPUT_FILE}")" ]; then
      if is_dry_run; then
        logInfoResult WARN "fail";
      else
        logInfoResult FAILURE "fail";
        exitWithErrorCode CANNOT_WRITE_OUTPUT_FILE;
      fi
    else
      if is_dry_run; then
        logInfoResult SUCCESS "valid";
      fi
    fi
  fi

  if    [ "x$(echo ${VIDEO_CODEC} | tr [:upper:] [:lower:])" != "xxvid" ] \
    &&  [ "x$(echo ${VIDEO_CODEC} | tr [:upper:] [:lower:])" != "xmpeg4" ] \
    &&  [ "x$(echo ${VIDEO_CODEC} | tr [:upper:] [:lower:])" != "xh264" ]; then
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
#    _result=$(lsdvd -t ${_track} -a ${DVD_DEVICE} 2> /dev/null | grep "Language: ${_audioLang}" | grep "Channels: ${AUDIO_CHANNELS}" | head -n 1 | cut -d ':' -f 2 | cut -d ',' -f 1 | xargs echo "127+" | bc 2> /dev/null);
#    if [ "x${_result}" == "x" ]; then
#      logInfoResult FAILURE "unavailable";
#    else
#      logInfoResult SUCCESS "${_result}";
#    fi
#  fi
  if [ "x${_result}" == "x" ]; then
    logInfo -n "Finding out audio id from locale preferences, or explicit ${_envVariable} variable (${_audioLang})";
    _aux=$(lsdvd -a ${DVD_DEVICE} 2> /dev/null | grep -C 10 "Title: ${_track}" | grep "Language: ${_audioLang}");
    if [ "x${_aux}" != "x" ]; then
      _result=$(echo ${_aux} | head -n 1 | cut -d ':' -f 2 | cut -d ',' -f 1 | xargs echo "127+" | bc);
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
  _result=$(lsdvd -s ${DVD_DEVICE} 2> /dev/null | grep -C 10 "Title: ${_track}" | grep "Language: ${_subtitleLang}" | head -n 1 | cut -d ':' -f 2 | cut -d ',' -f 1 2> /dev/null);
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

  local _result="$(lsdvd -s ${DVD_DEVICE} -t ${_track} | grep "Subtitle: ${_sid}" | awk '{print $4;}')";

  export RESULT="${_result}";
}

# Retrieves an undefined subtitle id
function retrieve_invalid_subtitle_id() {
  local _result="$(lsdvd -s ${DVD_DEVICE} 2> /dev/null | grep Subtitle | tail -n 1 | cut -d ' ' -f 2 | cut -d ',' -f 1)";
  _result=$((_result+1));

  export RESULT="${_result}";
}

function deprecated_extract_subs() {
  local _totalSubs=$(echo ${SUBTITLE_ID} | awk '{print NF;}');
  if [ ${_totalSubs} -gt 1 ]; then
    _aid="-aid ${_defaultAid}";
    _sid="fake";
    _index=1;
    _slang="$(echo ${_subtitleLangs} | awk -v i=${_index} '{print $i;}')";
    _afile="$(basename ${OUTPUT_FILE} .avi).${_slang}";
    _sfile="${_afile}.sub";
    _sid="$(echo ${SUBTITLE_ID} | awk -v i=${_index} '{print $i;}')";
    if [ "x${_sid}" != "" ]; then
      _sid="-sid ${_sid}";
      _index=$((_index+1));

      if is_dry_run; then

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

      if is_dry_run; then
        logInfo sub2srt "${_sfile}" "$(basename ${_sfile} .sub).srt";
      else
        if isLowerThanInfoEnabled; then
          logInfo "Converting ${_sfile} to $(basename ${_sfile} .sub).srt...";
        else
          logInfo -n "Converting ${_sfile} to $(basename ${_sfile} .sub).srt...";
        fi

        sub2srt "${_sfile}" "$(basename ${_sfile} .sub).srt";
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

# Processes given mencoder opts.
# - opts: the original options (with placeholders).
# - varName: the variable name.
# - varValue: the variable value.
function retrieve_mencoder_opts() {
  local _opts="${1}";
  local _varName="${2}";
  local _placeHolder="${3}";
  local _varValue="${4}";
  local _result="${_opts}";

  if [ "x${_varValue}" ==  "x" ]; then
    _result="$(echo ${_result} | sed "s|${_varName}=\${${_placeHolder}}||g")";
  else
    _result="$(echo ${_result} | sed "s|\${${_placeHolder}}|${_varValue}|g")";
  fi

  export RESULT="${_result}";
}

# Retrieves the video options for the first pass.
# Parameters:
# - crop: the crop options (optional).
# - bitrate: the bitrate (optional).
function retrieve_video_opts_first_pass() {
  local _crop="${_crop}";
  local _bitrate="${_bitrate}";

  local _result;

  process_mencoder_opts "${VIDEO_OPTS_FIRST_PASS}" "crop" "\${CROP}" "${_crop}";
  _result="${RESULT}";

  process_mencoder_opts "${_result}" "bitrate" "\${BITRATE}" "${_bitrate}";
  _result="${RESULT}";

  export RESULT="${_result}";
}

# Retrieves the video options for the first pass.
# Parameters:
# - crop: the crop options (optional).
# - bitrate: the bitrate (optional).
function retrieve_video_opts_second_pass() {
  local _crop="${_crop}";
  local _bitrate="${_bitrate}";

  local _result;

  process_mencoder_opts "${VIDEO_OPTS_SECOND_PASS}" "crop" "\${CROP}" "${_crop}";
  _result="${RESULT}";

  process_mencoder_opts "${_result}" "bitrate" "\${BITRATE}" "${_bitrate}";
  _result="${RESULT}";

  export RESULT="${_result}";
}

# Performs the first pass when encoding AVI files.
# Parameters:
# - input: the input source.
# - dvdDevice: the DVD device.
# - twoPassFile: the 2-pass file.
# - cropOpts: the crop options.
# - audioChannels: the audio channels.
# - audioLang: the audio language.
# - bitrate: the bitrate.
function first_pass() {
  local _input="${1}";
  local _dvdDevice="${2}";
  local _twoPassFile="${3}";
  local _cropOpts="${4}";
  local _audioChannels="${5}";
  local _audioLang="${6}";
  local _bitrate="${7}";

  retrieve_video_opts_first_pass "${_cropOpts}" "${_bitrate}";
  local _videoOptsFirstPass="${RESULT}";

  if [ -f ${_twoPassFile} ]; then
    logInfo -n "First pass...";
    logInfoResult SUCCESS "already done";
  else
    if isLowerThanInfoEnabled; then
      logInfo "First pass...";
    else
      logInfo -n "First pass...";
    fi

    if is_dry_run; then
      logInfo \
        mencoder "${_input}" \
        -passlogfile ${_twoPassFile} \
        ${_dvdDevice} \
        ${_videoOptsFirstPass} \
        ${AUDIO_OPTS_FIRST_PASS} \
        ${_cropOpts} \
        ${_audioChannels} \
        ${_audioLang} \
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
        ${_audioLang} \
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
}

# Performs the second pass.
# Parameters:
# - input: the input source.
# - dvdDevice: the DVD device.
# - twoPassFile: the 2-pass file.
# - cropOpts: the crop options.
# - audioChannels: the audio channels.
# - audioLang: the audio language.
# - audioId: the list of audio tracks.
# - undefinedSubtitleId: a missing subtitle id to avoid hard-coding subtitles
# in the video track.
# - bitrate: the bitrate.
function second_pass() {
  local _input="${1}";
  local _dvdDevice="${2}";
  local _outputFile="${3}";
  local _twoPassFile="${4}";
  local _cropOpts="${5}";
  local _audioChannels="${6}";
  local _audioLang="${7}";
  local _audioId="${8}";
  local _undefinedSubtitleId="${9}";
  local _bitrate="${10}";

  if isLowerThanInfoEnabled; then
    logInfo "Second pass...";
  else
    logInfo -n "Second pass...";
  fi

  retrieve_video_opts_second_pass "${_cropOpts}" "${_bitrate}";
  local _videoOptsSecondPass="${RESULT}";

  retrieve_invalid_subtitle_id;
  local _undefinedSubtitleId="${RESULT}";

  if is_dry_run; then
    logInfo \
      mencoder "${_input}" \
      -passlogfile ${_twoPassFile} \
      ${_dvdDevice} \
      ${_videoOptsSecondPass} \
      ${AUDIO_OPTS_SECOND_PASS} \
      ${_cropOpts} \
      ${_audioChannels} \
      ${_alang} \
      ${_audioId} \
      -sid ${_undefinedSubtitleId} \
      -o "${_outputFile}";
#      ${_sid} \
  else
    runCommandLongOutput \
      mencoder "${_input}" \
      -passlogfile ${_twoPassFile} \
      ${_dvdDevice} \
      ${_videoOptsSecondPass} \
      ${AUDIO_OPTS_SECOND_PASS} \
      ${_cropOpts} \
      ${_audioChannels} \
      ${_alang} \
      ${_aid} \
      -sid ${_undefinedSubtitleId} \
      -o "${_outputFile}";
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

}

# Merges all specified audio tracks into the final avi file.
# Parameters:
# - input the input source.
# - dvdDevice the DVD device.
# - outputFile the output file.
# - audioIds the ids of the audio tracks.
# - subtitleIds the ids of the subtitle tracks.
# - subtitleLangs the subtitle language list.
# - twoPassFile the 2-pass file.
function merge_audio_tracks_in_avi() {
  local _input="${1}";
  local _dvdDevice="${2}";
  local _outputFile="${3}";
  local _audioIds="${4}";
  local _subtitleIds="${5}";
  local _subtitleLangs="${6}";
  local _twoPassFile="${7}";
  local _trackId="${8}";

  local _audioId;  
  local _aid;
  local _slang;
  local _afile;
  local _sfile;
  local _aformat;

  local _totalAids=$(echo ${_audioIds} | awk '{print NF}');
  local _index;
  if [ ${_totalAids} -gt 1 ]; then
    _index=2;
    while [ ${_index} -le ${_totalAids} ]; do
      _audioId="$(echo ${audioIds} | awk -v i=${_index} '{print $i;}')";
      _aid="-aid ${_audioId}";
      _slang="$(echo ${_subtitleLangs} | awk -v i=${_index} '{print $i;}')";
      if [ "x${_slang}" == "x" ]; then
        _slang="en";
      fi
      retrieve_audio_format "${_dvdDevice}" "${_trackId}" "${_audioId}"
      _afile="$(basename ${_outputFile} .avi).${_slang}";
      _sfile="${_afile}.sub";
      _sid="-vobsubout ${_sfile} -vobsuboutindex 1 -sid $(echo ${_subtitleIds} | awk -v i=${_index} '{print $i;}')";
      _index=$((_index+1));

      if is_dry_run; then

        logInfo \
          mencoder "${_input}" \
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
            mencoder "${_input}" \
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

      if is_dry_run; then

        logInfo \
          avimerge \
          -i "${_outputFile}" \
          -o "${_outputFile}.in-progress" \
          -p "${_afile}.avi";
        logInfo mv "${_outputFile}.in-progress" "${_outputFile}";

      else

        if isLowerThanInfoEnabled; then
          logInfo "Merging audio track into existing video...";
        else
          logInfo -n "Merging audio track into existing video...";
        fi

        runCommandLongOutput \
          avimerge \
          -i "${_outputFile}" \
          -o "${_outputFile}.in-progress" \
          -p "${_afile}.avi" \
        && mv "${_outputFile}.in-progress" "${_outputFile}";

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
}

function deprecated_extract_subs() {
  local _totalSubs=$(echo ${SUBTITLE_ID} | awk '{print NF;}');
  if [ ${_totalSubs} -gt 1 ]; then
    _aid="-aid ${_defaultAid}";
    _sid="fake";
    _index=1;
    _slang="$(echo ${_subtitleLangs} | awk -v i=${_index} '{print $i;}')";
    _afile="$(basename ${OUTPUT_FILE} .avi).${_slang}";
    _sfile="${_afile}.sub";
    _sid="$(echo ${SUBTITLE_ID} | awk -v i=${_index} '{print $i;}')";

    if [ "x${_sid}" != "" ]; then
      _sid="-sid ${_sid}";
      _index=$((_index+1));

      if is_dry_run; then

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

      if is_dry_run; then
        logInfo sub2srt "${_sfile}" "$(basename ${_sfile} .sub).srt";
      else
        if isLowerThanInfoEnabled; then
          logInfo "Converting ${_sfile} to $(basename ${_sfile} .sub).srt...";
        else
          logInfo -n "Converting ${_sfile} to $(basename ${_sfile} .sub).srt...";
        fi

        sub2srt "${_sfile}" "$(basename ${_sfile} .sub).srt";
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

function is_dvd() {
  local _result=0;

  if    [ "${INPUT##dvd:\/\/}" != "${INPUT}" ] ; then
#     && [ "x${_dvdDevice}" != "x${DVD_DEVICE_DEFAULT}" ] \
#     && [ "${_dvdDevice##dvd:\/\/}" != "${_dvdDevice}" ]; then
    result=1;
  fi

  return ${_result};
}

function retrieve_dvd_device() {
  local _result="";

  if [ "x${DVD_DEVICE}" != "x${DVD_DEVICE_DEFAULT}" ]; then
    _result="-dvd-device ${DVD_DEVICE}";
  fi

  export RESULT="${_result}";
}

function retrieve_track() {
  local _result="";

  if is_dvd; then
    # It's a dvd, let's check if there's actually a track
    # specified or we need to let lsdvd guess it.
    _result="${INPUT##dvd:\/\/}";
    if [ "x${_track}" == "x" ]; then
      logInfo -n "Finding out longest track since none was specified";
      _track=$(lsdvd -s ${DVD_DEVICE} 2> /dev/null | tail -n 2 | head -n 1 | cut -d ':' -f 2 | tr -d '[:space:]');
      if [ "x${_track}" == "x" ]; then
        logInfoResult FAILURE "fail";
        exitWithErrorCode CANNOT_GUESS_CANDIDATE_DVD_TRACK;
      else
        logInfoResult SUCCESS "${_track}";
        INPUT="dvd://${_track}";
      fi
    fi
    _result=${_result##0};
    if [ $((_result)) -lt 10 ]; then
      _result="0${_result}";
    fi
  fi

  export RESULT="${_result}";
}

function retrieve_audio_id() {
  local _result="";

  if is_dvd; then
    if [ "x${AUDIO_ID## }" == "x" ]; then
      retrieve_audio_id_from_audio_lang "AUDIO_LANG" "${AUDIO_LANG}";
      _result="${RESULT}";
      if    [ "x${RIP_EXTRA_LANG}" != "x" ] \
         && [ "x${RIP_EXTRA_LANG}" != "x${AUDIO_LANG}" ]; then
        retrieve_audio_id_from_audio_lang "RIP_EXTRA_LANG" "${RIP_EXTRA_LANG}";
        if [ "x${RESULT}" != "x${AUDIO_ID}" ]; then
          _audioId="${_result} ${RESULT}";
        fi
      fi
    fi
  fi

  export RESULT="${_result}";

}

function subtitle_processing_enabled() {
  local _result=1;

  if [ "x${DISABLE_SUBTITLE_PROCESSING}" == "x" ]; then
    _result=0;
  fi

  return ${_result};
}

function retrieve_subtitle_langs() {
  local _resultId="";
  local _resultLangs="";

  if subtitle_processing_enabled; then
    if [ "x${SUBTITLE_ID## }" == "x" ]; then
      retrieve_subtitle_id_from_subtitle_lang ${_track} "${SUBTITLE_LANG}";
      _resultId="${RESULT}";
      _resultLangs="${SUBTITLE_LANG}";
      if [ "x${RIP_EXTRA_LANG}" != "x" ]; then
        retrieve_subtitle_id_from_subtitle_lang ${_track} "${RIP_EXTRA_LANG}";
        if [ "x${RESULT}" != "x${SUBTITILE_ID}" ]; then
          _result_id="${SUBTITLE_ID} ${RESULT}";
          _resultLangs="${_resultLangs} ${RIP_EXTRA_LANG}";
        fi
      fi
    fi
  fi

  export RESULT="${_resultId} ${_resultLangs}";
}

function is_dry_run() {
  local _result=1;

  if [ "x${DRY_RUN}" != "x" ]; then
    _result=0;
  fi

  return ${_result};
}

# Dumps the contents of a dvd to a vob file.
function dump_dvd() {
  local _result="${OUTPUT_FILE%.*}.vob";
  if [ -f ${_result} ]; then
    logInfo "Using already existing ${_result}";
  else
    if is_dry_run; then
      logInfo ${MPLAYER_COMMAND} ${DVD_COPY_EXTRA_OPTS} -dumpstream -dumpfile ${_result} ${INPUT};
    else
      logInfo -n "Copying ${INPUT} to ${_result}";
      runCommandLongOutput \
        ${MPLAYER_COMMAND} ${_dvdDevice} ${DVD_COPY_EXTRA_OPTS} -dumpstream -dumpfile ${_result} ${INPUT};
      logInfoResult SUCCESS "done";
    fi
  fi

  export RESULT="${_result}";
}

# Checks whether given language is supported by pgm2txt.
# Parameters:
# - lang: the language.
function is_language_supported_by_pgm2txt() {
  local _lang="${1}";
  local _result=0;
  local _squote="'";

  if    [ "x${_lang}" != "xen" ] \
     && [ "x${_lang}" != "xfr" ] \
     && [ "x${_lang}" != "xde" ]; then
    logInfo -n "Skipping subtitle extraction for ${_squote}${_slang}${_squote} since it${_squote}s not supported by pgm2txt";
    logInfoResult FAILURE "skip";
    _result=1;
  fi

  return ${_result};
}

# Converts given hexadecimal value to a decimal number.
# Parameters:
# - hexValue: the hex value to convert.
function hex_2_dec() {
  local _hexValue="${1}";
  local _result="$(cat <<EOF | bc
ibase=16
obase=10
${_hexValue}
EOF)";
  export RESULT="${_result}";
}

# Converts given hexadecimal value to a decimal number.
# Parameters:
# - decValue: the decimal value to convert.
function dec_2_hex() {
  local _decValue="${1}";
  local _result="$(cat <<EOF | bc
ibase=10
obase=16
${_decValue}
EOF)";
  export RESULT="${_result}";
}

# Calls to tccat to extract subtitles.
function extract_subtitles_with_tccat() {
  local _vobFile="${1}";
  local _track="${2}";
  local _outputFile="${3}";
  local _outputFolder="${4}";
  local _slang="${5}";
  local _sindex="${6}";
  local _resultCode=0;
  local _squote="'";
  local _result="${_outputFolder}/${_outputFile}-${_slang}-${_sindex}.ps1";

  dec_2_hex $((32+${_sindex}));
  _hexSid="${RESULT}";
   hex_2_dec ${_hexSid};
  _decSid="${RESULT}";

  logDebug -n "tccat -i ${_vobFile} -T ${_track#0},-1 | tcextract -x ps1 -t vob -a 0x${_hexSid} > ${_result}"
  if is_dry_run; then
    logDebugResult SUCCESS "dry-run";
  else
    tccat -i ${_vobFile} -T ${_track#0},-1 | tcextract -x ps1 -t vob -a 0x${_hexSid} > "${_result}";
    _resultCode=$?;
    if [ ${_resultCode} -eq 0 ]; then
      logDebugResult SUCCESS "done"
      export RESULT="${_result}";
    else
      logDebugResult FAILURE "failed"
    fi
  fi

  return ${_resultCode};
}

# Converts subtitles with subtitle2vobsub.
# Parameters:
# - vts_01_0.ifo: the VTS_01_0.IFO file.
# - outputFile: the name of the output file.
# - outputFolder: the output folder.
# - slang: the subtitle language.
# - sindex: the subtitle index.
# - ps1: the .ps1 file.
function convert_subtitles_with_subtitle2vobsub() {
  local _vts010ifo="${1}";
  local _outputFile="${2}";
  local _outputFolder="${3}";
  local _slang="${4}";
  local _sindex="${5}";
  local _ps1="${6}";
  local _resultCode=0;
  local _squote="'";
  local _result="${_outputFolder}/${_slang}-subs";

  logDebug -n subtitle2vobsub -o "$_result}" -i ${_vts010ifo} -a ${_slang} < "${_ps1}";
  if is_dry_run; then
    logDebugResult SUCCESS "dry-run";
  else
    subtitle2vobsub -o "${_result}" -i ${_vts010ifo} -a ${_slang} < "${_ps1}";
    _resultCode=$?;
    if [ ${_resultCode} -eq 0 ]; then
      logDebugResult SUCCESS "done"
      export RESULT="${_result}";
    else
      logDebugResult FAILURE "failed"
    fi
  fi

  return ${_resultCode};
}

# Converts subtitles with subtitle2pgm.
# Parameters:
# - outputFolder: the output folder.
# - ps1: the .ps1 file.
function convert_subtitles_with_subtitle2pgm() {
  local _outputFolder="${1}";
  local _ps1="${2}";
  local _result=0;
  local _squote="'";

  logDebug -n "subtitle2pgm -o ${_outputFolder} -c ${SUBTITLE_GREY_LEVELS} < ${_ps1}"

  if is_dry_run; then
    logDebugResult SUCCESS "done"
  else
    subtitle2pgm -o "${_outputFolder}" -c ${SUBTITLE_GREY_LEVELS} < "${_ps1}"

    _result=$?;
    if [ ${_result} -eq 0 ]; then
      logDebugResult SUCCESS "done"
    else
      logDebugResult FAILURE "failed"
    fi
  fi

  return ${_result};
}

# Converts subtitles with pgm2txt.
# Parameters:
# - outputFile: the output file.
# - slang: the subtitle language.
# - sindex: the subtitle index.
function convert_subtitles_with_pgm2txt() {
  local _outputFile="${1}";
  local _slang="${2}";
  local _sindex="${3}";
  local _result=0;
  local _squote="'";

  logDebug -n "pgm2txt -f ${_slang} ${_outputFile}-${_sindex}";

  if is_dry_run; then
    logDebugResult SUCCESS "done"
  else
    pgm2txt -f ${_slang} ${_outputFile}-${_sindex};

    _result=$?;
    if [ ${_result} -eq 0 ]; then
      logDebugResult SUCCESS "done"
    else
      logDebugResult FAILURE "failed"
    fi
  fi

  return ${_result};
}

# Converts subtitles with pgm2txt.
# Parameters:
# - outputFolder: the output folder.
# - outputFile: the output file.
# - slang: the subtitle language.
# - sindex: the subtitle index.
function spell_check_subtitles() {
  local _outputFolder="${1}";
  local _outputFile="${2}";
  local _slang="${3}";
  local _sindex="${4}";
  local _result=0;
  local _dialect;
  local _langHash;

  case "x${_slang}" in
    "en") _dialect=${DEFAULT_ENGLISH_DIALECT};
          ;;
    "en") _dialect="${DEFAULT_SPANISH_DIALECT}";
          ;;
    *) ;;
  esac

  _langHash="${ISPELL_HASH_FOLDER}/${_dialect}${ISPELL_HASH_FILE_SUFFIX}";

  if [ -f "${_langHash}" ]; then
    logDebug -n "ispell -d ${_dialect} ${_outputFolder}/${_outputFile}-${s}";

    if is_dry_run; then
      logDebugResult SUCCESS "done";
    else
      ispell -d ${_dialect} ${_outputFolder}/${_outputFile}-${_sindex} > /dev/null 2> /dev/null;
      _result=$?;
      if [ ${_result} -eq 0 ]; then
        logDebugResult SUCCESS "done";
      else
        _result=1;
        logDebugResult FAILURE "failed";
      fi
    fi
  fi

  return ${_result};
}

# Converts subtitles to .srt format.
# Parameters:
# - outputFolder: the output folder.
# - outputFile: the output file.
# - slang: the subtitle language.
# - sindex: the subtitle index.
function convert_subtitles_to_srt() {
  local _outputFolder="${1}";
  local _outputFile="${2}";
  local _slang="${3}";
  local _sindex="${4}";
  local _result=0;
  local _squote="'";

  logDebug -n "srttool -s -w < ${_outputFolder}/${_outputFile}-${_sindex}.srtx > ${_outputFile}.${_slang}.srt";

  if is_dry_run; then
    logDebugResult SUCCESS "done"
  else
    srttool -s -w < "${_outputFolder}/${_outputFile}-${_sindex}.srtx" > "${_outputFile}.${_slang}.srt";

    _result=$?;
    if [ ${_result} -eq 0 ]; then
      logDebugResult SUCCESS "done"
    else
      logDebugResult FAILURE "failed"
    fi
  fi

  return ${_result};
}

# Extracts subtitles.
# Parameters:
# - vobFile: the VOB file.
# - track: the track.
# - subtitleId: the id of the subtitle.
# - outputFile: the output file.
# - vts010ifo: the VTS_01_0.ifo file.
function extract_subtitles() {
  local _vobFile="${1}";
  local _track="${2}";
  local _subtitleId="${3}";
  local _outputFile="${4}";
  local _vts010ifo="${5}";
  local _slang;
  local _squote="'";
  local _ps1;

  if subtitle_processing_enabled; then

    for s in $(echo ${_subtitleId} | sed 's| |\n|g' | sort | uniq); do

      retrieve_sub_language "${_track}" "${s}";
      _slang="${RESULT}";

      if ! isLowerThanInfoEnabled; then
        logDebug -n "Extracting ${_squote}${_slang}${_squote} (${s}) subtitle stream";
      fi

      createTempFolder;
      _tempFolder="${RESULT}";

      if extract_subtitles_with_tccat \
        "${_vobFile}" \
        "${_track}" \
        "${_outputFile}" \
        "${_tempFolder}" \
        "${_slang}" \
        "${s}"; then

        local _ps1="${RESULT}";

        if convert_subtitles_with_subtitle2vobsub \
          "${_vts010ifo}" \
          "${_outputFile}" \
          "${_tempFolder}" \
          "${_slang}" \
          "${s}"; then

          if convert_subtitles_with_subtitle2pgm "${_tempFolder}" "${_ps1}"; then

            if    is_language_supported_by_pgm2txt "${_slang}" \
               && convert_subtitles_with_pgm2txt \
              "${_outputFile}" "${_slang}" "${_sindex}"; then

              spell_check_subtitles \
                "${_tempFolder}" "${_outputFile}" "${_slang}" "${s}";

              convert_subtitles_to_srt \
                "${_tempFolder}" "${_outputFile}" "${_slang}" "${s}";
            fi
          fi
        fi
      fi

      rm -f ${_tempFolder}/${_outputFile}-${_slang}*.{pgm,srtx,ps1} 2> /dev/null

    done;
  fi

}

function eject_disabled() {
  local _result=0;

  if [ "x${DISABLE_EJECT}" == "x" ]; then
    _result=1;
  fi

  return ${_result};
}

function eject() {
  if eject_disabled; then
    logInfo -n "Ejecting DVD since it's not longer needed (background)"
          
    if is_dry_run; then
      logInfoResult SUCCESS "dry-run";
      logInfo -n "eject ${DVD_DEVICE}";
    else
      eject ${DVD_DEVICE} 2> /dev/null &
    fi
    if [ $? == 0 ]; then
      logInfoResult SUCCESS "done"
    else
      logInfoResult FAILURE "failed"
    fi
  fi
}

function audio_channels_specified() {
  local _result=0;

  if [ "x${AUDIO_CHANNELS}" != "x" ]; then
    _result=1;
  fi

  return ${_result};
}

# Retrieves the file name of the 2-pass file.
# Parameters:
# - outputFile the output file.
function retrieve_two_pass_file_log() {
  local _outputFile="${1}";

  local _result="$(dirname "{_outputFule}")/${_outputFile}.log";

  export RESULT="${_result}";
}

function crop_detection_enabled() {
  local _result=0;

  if [ "x${SKIP_CROP_DETECTION}" == "x" ]; then
    _result=1;
  fi

  return ${_result};
}

# Retrieves the crop options.
# Parameters:
# - dvdDevice the DVD device.
function retrieve_crop_opts() {
  local _dvdDevice="${1}";
  local _result="";

  if crop_detection_enabled; then
    runCommandLongOutput \
      ${MPLAYER_COMMAND} \
        ${_dvdDevice} -ss ${CROP_DETECTION_START} -endpos ${CROP_DETECTION_DURATION} -vf cropdetect \
        "${INPUT}";
    local _resultCode=$?;
    logInfo -n "Detecting crop window...";
    _result=$(grep "\[CROP\]" "${RESULT}" 2> /dev/null | tail -n 1 | sed 's/.*(\(.*\)).*/\1/g');
    if [ ${_resultCode} == 0 ]; then
      local _fields=$(echo "${_result##*=}" | awk -F":" '{print NF;}');
      if [ "${_fields}" == "4" ]; then
        logInfoResult SUCCESS "${_result##*=}";
      else
        _result="";
        logInfoResult FAILURE "failed";
      fi
    else
      _result="";
      logInfoResult FAILURE "failed";
    fi
  fi

  export RESULT="${_result}";
}

function audio_id_specified() {
  local _result=0;

  if [ "x${AUDIO_ID}" != "x" ]; then
    _result=1;
  fi

  return ${_result};
}

# Retrieves the default id of given audio track.
# Parameters
# - audioId the audio track.
function retrieve_default_aid() {
  local _audioId="${1}";
  local _result="$(echo ${_audioId} | cut -d ' ' -f 1 2> /dev/null)";

  export RESULT="${_result}";
}

# Retrieves the default language of given list.
# Parameters
# - subtitleLangs the space-sparated subtitle languages.
function retrieve_default_slang() {
  local _subtitleLangs="${1}";
  local _result="$(echo ${_subtitleLangs} | cut -d ' ' -f 1 2> /dev/null)";

  export RESULT="${_result}";
}

function audio_lang_specified() {
  local _result=0;

  if [ "x${AUDIO_LANG}" != "x" ]; then
    _result=1;
  fi

  return ${_result};
}

function subtitle_id_specified() {
  local _result=0;

  if [ "x${SUBTITLE_ID}" != "x" ]; then
    _result=1;
  fi

  return ${_result};
}

# Mounts the DVD in given folder.
# -dvdDevice: the DVD device.
# -mountDir: the mount point.
function mount_dvd() {
  local _dvdDevice="${1}";
  local _mountDir="${2}";

  logInfo -n "Mounting DVD";
  if is_dry_run; then
    logInfoResult "dry-run";
  else
    sudo mount "${_dvdDevice}" "${_mountDir}" > /dev/null 2> /dev/null;
    if [ $? -eq 0 ]; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILED "failed";
    fi
  fi
}

# Unmounts the DVD previously mapped to given folder.
# -mountDir: the mount point.
function umount_dvd() {
  local _mountDir="${1}";

  logInfo -n "Umounting DVD";
  if is_dry_run; then
    logInfoResult "dry-run";
  else
    sudo umount "${_mountDir}" > /dev/null 2> /dev/null;
    if [ $? -eq 0 ]; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILED "failed";
    fi
  fi
}

# Copies VTS_01_0.IFO file.
function copy_vts_01_0_ifo() {
  local _mountFolder="${1}";
  local _destination="${2}";

  logInfo -n "Copying VIDEO_TS/VTS_01_0.IFO";
  if is_dry_run; then
    logInfoResult "dry-run";
  else
    cp "${_mountFolder}/video_ts/vts_01_0.ifo" "${_destination}" > /dev/null 2> /dev/null;
    if [ $? -eq 0 ]; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILED "failed";
    fi
  fi
}

# Retrieves the subtitle id from given identifier.
# Parameters
# - sid: the id of the subtitle.
function retrieve_default_sid() {
  local _subtitleId="${1}";
  local _result="$(echo ${_subtitleId} | cut -d ' ' -f 1 2> /dev/null)";
  export RESULT="${_result}";
}

# Calls mplayer and mencoder to perform a two-phase encoding in xdiv+mp3.
function encode_avi() {

  local _dvdDevice;
  local _slang;
  local _track;
  local _audioId;
  local _newInput;
  local _audioChannels;
  local _twoPassFile;
  local _cropOpts;
  local _aid;
  local _defaultAid;
  local _alang;
  local _sid;
  local _sfile;
  local _defaultSid;
  local _defaultSLang;
  local _mountFolder;
  local _tempFolder;
  local _vts010ifo;

  retrieve_dvd_device;
  _dvdDevice="${RESULT}";

  if is_dvd; then
    retrieve_track;
    _track="${RESULT}";
    retrieve_audio_id;
    _audioId="${RESULT}";
    
    if subtitle_processing_enabled; then
      retrieve_subtitle_langs;
      _subtitleId="$(echo ${RESULT} | cut -d ' ' -f 1 2> /dev/null)";
      _subtitleLangs="$(echo ${RESULT} | cut -d ' ' -f 2- > /dev/null)";
    fi

    dump_dvd;
    _newInput="${RESULT}";

    if subtitle_processing_enabled; then
        createTempFolder;
        _mountFolder="${RESULT}";

        mount_dvd "${_dvdDevice}" "${_mountFolder}";

        createTempFolder;
        _tempFolder="${RESULT}";

        copy_vts_01_0_ifo "${_mountFolder}" "${_tempFolder}";
        umount_dvd "${_mountFolder}";

        extract_subtitles "${_newInput}" "${_track}" "${_subtitleId}" "${OUTPUT_FILE}" "${_vts010ifo}";
    fi

    eject;

    INPUT="${_newInput}";
  fi

  if audio_channels_specified; then
    _audioChannels="-channels ${AUDIO_CHANNELS}";
  fi

  retrieve_two_pass_file_log "${OUTPUT_FILE}";
  _twoPassFile="${RESULT}";

  retrieve_crop_opts "${_dvdDevice}";
  _cropOpts="${RESULT}";

  if audio_id_specified; then
    retrieve_default_aid "${AUDIO_ID}";
    _defaultAid="${RESULT}";
    _aid="-aid ${_defaultAid}";
  fi

  if audio_lang_specified; then
    _alang="-alang ${AUDIO_LANG}";
  fi

  if subtitle_id_specified; then
    retrieve_default_sid "${SUBTITLE_ID}";
    _defaultSid="${RESULT}";
    retrieve_default_slang "${_subtitleLangs}";
    _defaultSLang="${RESULT}";
    _sid="-vobsubout $(basename ${OUTPUT_FILE} .avi).${_defaultSLang}.sub -vobsuboutindex 0 -sid ${_defaultSid}";
  fi

  first_pass \
    "${INPUT}" \
    "${_dvdDevice}" \
    "${_twoPassFile}" \
    "${_cropOpts}" \
    "${_audioChannels}" \
    "${_alang}" \
    "${BITRATE}";

  second_pass \
    "${INPUT}" \
    "${_dvdDevice}" \
    "${OUTPUT_FILE}" \
    "${_twoPassFile}" \
    "${_cropOpts}" \
    "${_audioChannels}" \
    "${_alang}" \
    "${_aid}" \
    "${_undefinedSubtitleId}" \
    "${BITRATE}";

  merge_audio_tracks_in_avi \
    "${INPUT}" \
    "$_dvdDevice}" \
    "${OUTPUT_FILE}" \
    "${AUDIO_ID}" \
    "${SUBTITLE_ID}" \
    "${_subtitleLangs}" \
    "${_twoPassFile}" \
    "${_track}";

  logInfo "Finished ripping ${INPUT} to ${OUTPUT_FILE}";
}

# Dumps the selected audio files.
# Parameters:
# - input: the input source.
# - dvdDevice: the DVD device.
# - outputFile: the output file name (to follow a common naming conventions on the audio files).
# - audioIds: the ids of the audio tracks.
# - langs: the subtitle language list.
# - twoPassFile: the 2-pass file.
function dump_audio_files() {
  local _input="${1}";
  local _dvdDevice="${2}";
  local _outputFile="${3}";
  local _audioIds="${4}";
  local _langs="${5}";
  local _twoPassFile="${7}";
  local _trackId="${8}";
  local _result="";

  local _audioId;  
  local _slang;
  local _afile;
  local _sfile;
  local _aformat;

  local _totalAids=$(echo ${_audioIds} | awk '{print NF}');
  local _index;
  if [ ${_totalAids} -gt 1 ]; then
    _index=2;
    while [ ${_index} -le ${_totalAids} ]; do
      _audioId="$(echo ${audioIds} | awk -v i=${_index} '{print $i;}')";
      _slang="$(echo ${_langs} | awk -v i=${_index} '{print $i;}')";
      if [ "x${_slang}" == "x" ]; then
        _slang="en";
      fi
      retrieve_audio_format "${_dvdDevice}" "${_trackId}" "${_audioId}"
      _aformat="${RESULT}";
      _afile="${_outputFile##.*}.${_slang}";
      _sfile="${_afile}.sub";
      _index=$((_index+1));

      dump_audio_file \
        "${_dvdDevice}" \
        "${_afile}.${_aformat}" \
        "${_audioId}" \
        "${_twoPassFile}";

      _result="${_result} ${_afile}.${_aformat}";          
    done
  fi

  export RESULT="${_result}";
}

# Dumps the selected audio file.
# Parameters:
# - dvdDevice: the DVD device.
# - outputFile: the output audio file.
# - audioId: the audio id.
# - twoPassFile: the 2-pass file.
function dump_audio_file() {
  local _dvdDevice="${1}";
  local _outputFile="${2}";
  local _audioId="${3}";
  local _twoPassFile="${4}";
  local _aid="-aid ${_audioId}";

  if [ -f ${_outputFile} ]; then
    logInfo "Using already existing ${_outputFile}";
    logInfoResult SUCCESS "skip";
  else
    if is_dry_run; then
      logInfo \
        mencoder "${_input}" \
          -passlogfile ${_twoPassFile} \
          ${_dvdDevice} \
          -ovc frameno \
          ${AUDIO_OPTS_SECOND_PASS} \
          ${_aid} \
          -o "${_outputFile}";
    else
      if isLowerThanInfoEnabled; then
        logInfo "Ripping additional audio/subtitiles...";
      else
        logInfo -n "Ripping additional audio/subtitiles...";
      fi

      runCommandLongOutput \
        mencoder "${_input}" \
          -passlogfile ${_twoPassFile} \
          ${_dvdDevice} \
          -ovc frameno \
          ${AUDIO_OPTS_SECOND_PASS} \
          ${_aid} \
          -o "${_outputFile}";
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
}

# Retrieves the audio formats.
# Parameters:
# - dvdDevice: the DVD device.
# - trackId: the track id.
# - audioId: the audio id.
function retrieve_audio_format() {
  local _dvdDevice="${1}";
  local _trackId="${2}";
  local _audioId="${3}";
  local _audioTrack="$(_audioId-127)";
  
  local _result=$(_lsdvd -s "${_dvdDevice}" -t ${_trackId} -a -v 2> /dev/null | grep "Audio: ${_audioTrack}" | tail -n 1 | awk '{print $8;}' | cut -d ',' -f 1);

  export RESULT="${_result}";
}

# Retrieves the duration.
# Parameters:
# - dvdDevice: the DVD device.
# - trackId: the track id.
function retrieve_duration() {
  local _dvdDevice="${1}";
  local _trackId="${2}";
  local _result=$(_lsdvd -s "${_dvdDevice}" -t ${_trackId} 2> /dev/null | grep Length | tail -n 1 | awk '{print $4;}' | cut -d '.' -f 1);

  export RESULT="${_result}";
}

# Retrieves the bitrate.
# Parameters:
# - duration: the duration (hh:mm:ss).
# - audioFile: the audio file to analyze.
# - idxFile: the index file to analyze.
# - subFile: the subtitle file to analyze.
function retrieve_bitrate() {
  local _duration="${1}";
  local _audioFile="${2}";
  local _idxFile="${3}";
  local _subFile="${4}";
  local _overhead=1.5;
  local _result="";

  case "$(echo ${CONTAINER_FORMAT} 2> /dev/null | tr '[:upper:]' '[:lower:]' 2> /dev/null)" in
    "mkv") _overhead=0.5;
           ;;
    "avi") _overhead=1.5;
           ;;
    *)     _overhead=1.0;
           ;;
  esac

  if [ -x $(which bitrate.py 2> /dev/null) ]; then
    _result=$(bitrate.py -o ${_overhead} -t ${MKV_TARGET_SIZE} "${_duration}" "${_audioFile}" "${_idxFile}" "${_subFile}" 2> /dev/null);
  fi

  if [ "x${_result}" == "x" ]; then
    _result="${DEFAULT_BITRATE}";
  fi

  export RESULT="${_result}";
}

# Extracts the chapter information.
# - dvdDevice: the DVD device.
# - track: the track.
# - destinationFolder: the destination folder.
function extract_chapter_information() {
  local _dvdDevice="${1}";
  local _track="${2}";
  local _destinationFolder="${3}";
  local _result="${_destinationFolder}/chapters.txt";

  dvdxchap -t ${_track} ${_dvdDevice} 2> /dev/null > "${_result}";
  if [ $? -ne 0 ]; then
    _result="";
  fi

  export RESULT="${_result}";
}

# Merges all audio/video/subtitles into a Matroska file.
function mkv_merge() {
  local _title="${1}";
  local _outputFile="${2}";
  local _chaptersFile="${3}";
  local _audioFiles="${4}";
  local _subtitleFiles="${5}";

  if is_dry_run; then
    logInfo \
      runCommandLongOutput \
        mkvmerge --title "${_title}" -o ${_outputFile}.mkv \
          --chapters ${_chaptersFile} \
          --default-duration 0:${H264_VIDEO_FPS}fps \
          -A ${_videoFile} ${_audioFiles} ${_subtitleFiles};
  else
    logInfo -n "Creating Matroska file...";

    runCommandLongOutput \
      mkvmerge --title "${_title}" -o ${_outputFile}.mkv \
        --chapters ${_chaptersFile} \
        --default-duration 0:${H264_VIDEO_FPS}fps \
        -A ${_videoFile} ${_audioFiles} ${_subtitleFiles};
    if [ $? == 0 ]; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILURE "fail";
      logDebugFileContents "${RESULT}";
      exitWithErrorCode ERROR_CREATING_MKV_FILE;
    fi
  fi
}

# Guesses the title.
# Parameters:
# - outputFile: the output file.
function guess_title() {
  local _fileName="${1}";
  local _result="$(echo ${fileName} | tr '[:upper:]' '[:lower:]' | tr '-' ' ' | tr '_' ' ' | sed 's/^.\|[Az]/\U&/g')";

  export RESULT="${_result}";
}

# Calls mplayer and mencoder to perform a two-phase encoding in mkv.
function encode_mkv() {

  local _dvdDevice;
  local _slang;
  local _track;
  local _audioId;
  local _newInput;
  local _audioChannels;
  local _twoPassFile;
  local _cropOpts;
  local _aid;
  local _defaultAid;
  local _alang;
  local _sfile;
  local _mountFolder;
  local _tempFolder;
  local _vts010ifo;
  local _duration;
  local _audioFile;
  local _idxFile;
  local _subFile;
  local _chaptersFile;
  local _title;

  retrieveDvdDevice;
  _dvdDevice="${RESULT}";

  if is_dvd; then
    retrieve_track;
    _track="${RESULT}";
    retrieve_duration "${_dvdDevice}" "${_track}";
    _duration="${RESULT}";
    retrieve_audio_id;
    _audioId="${RESULT}";

    if subtitle_processing_enabled; then
      retrieve_subtitle_langs;
      _subtitleId="$(echo ${RESULT} | cut -d ' ' -f 1 2> /dev/null)";
      _subtitleLangs="$(echo ${RESULT} | cut -d ' ' -f 2- > /dev/null)";
    fi

    dump_dvd;
    _newInput="${RESULT}";

    dump_audio_files() \
      "${_newInput}" \
      "${_dvdDevice}" \
      "${OUTPUT_FILE}" \
      "${_audioIds}" \
      "${_subtitleLangs}" \
      "${_twoPassFile}" \
      "${_track}";
    _audioFiles="${RESULT}";

    createTempFolder;
    _mountFolder="${RESULT}";

    mount_dvd "${_dvdDevice}" "${_mountFolder}";

    createTempFolder;
    _tempFolder="${RESULT}";

    copy_vts_01_0_ifo "${_mountFolder}" "${_tempFolder}";
    umount_dvd "${_mountFolder}";

    extract_chapter_information "${_dvdDevice}" "${_track}" "${_tempFolder}";
    _chaptersFile="${RESULT}";

    extract_subtitles "${_newInput}" "${_track}" "${_subtitleId}" "${OUTPUT_FILE}" "${_vts010ifo}";

    eject;

    INPUT="${_newInput}";
  fi

  if audio_channels_specified; then
    _audioChannels="-channels ${AUDIO_CHANNELS}";
  fi

  retrieve_two_pass_file_log "${OUTPUT_FILE}";
  _twoPassFile="${RESULT}";

  retrieve_crop_opts "${_dvdDevice}";
  _cropOpts="${RESULT}";

  if audio_id_specified; then
    retrieve_default_aid "${AUDIO_ID}";
    _defaultAid="${RESULT}";
    _aid="-aid ${_defaultAid}";
  fi

  if audio_lang_specified; then
    _alang="-alang ${AUDIO_LANG}";
  fi

  retrieve_bitrate "${_duration}" "${_audioFile}" "${_idxFile}" "${_subFile}";
  _bitrate="${RESULT}";

  first_pass \
    "${INPUT}" \
    "${_dvdDevice}" \
    "${_twoPassFile}" \
    "${_cropOpts}" \
    "${_audioChannels}" \
    "${_alang}" \
    "${_bitrate}";

  second_pass \
    "${INPUT}" \
    "${_dvdDevice}" \
    "${OUTPUT_FILE}" \
    "${_twoPassFile}" \
    "${_cropOpts}" \
    "${_audioChannels}" \
    "${_alang}" \
    "${_aid}" \
    "${_undefinedSubtitleId}" \
    "${_bitrate}";

  guess_title "${_outputFile}";
  _title="${RESULT}";

  mkv_merge
    "${_title}" \
    "${_outputFile}.mkv" \
    "${_chaptersFile}" \
    "${_outputFile}" \
    "${_audioFiles}" \
    "${_subtitleFiles}";

  logInfo "Finished ripping ${INPUT} to ${OUTPUT_FILE}";
}

function main() {
  case "$(echo ${CONTAINER_FORMAT} 2> /dev/null| tr '[:upper:]' '[:lower:]' 2> /dev/null)" in
    "mkv") encode_mkv $@;
           ;;
    "avi") encode_avi $@;
           ;;
    *) exitWithErrorCode UNSUPPORTED_CONTAINER_FORMAT;
       ;;
  esac
}
