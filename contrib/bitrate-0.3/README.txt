===================
 bitrate.py Manual
===================
------------------------------
Yet another bitrate calculator
------------------------------

:author: Marc 'BlackJack' Rintsch
:contact: marc@rintsch.de
:date: 2005-01-15
:version: 0.3
:copyright: This document has been placed in the public domain.

.. meta::
   :description: Manual for the bitrate.py script.
   :keywords: video, bitrate, calculator, XviD, Matroska, AVI, Python

.. contents::
.. sectnum::

Name
====

bitrate.py -- a bitrate calculator for video/audio data.


Synopsis
========
::

  bitrate.py [-h|--help|--version]
  bitrate.py [options] length(s) [file ...]

The length argument has '[[<hours>:]<minutes>:]<seconds>' format.
Every value may "overflow" i.e. it's okay to type ``1:90:0`` which is
actually 2 hours and a half.  Additional lengths, separated by commas,
are added to one final length.

The given files' sizes are taken into account when calculating the
bitrate.


Description
===========

It's a little Python_ script which calculates the maximum bitrate for
a stream that has to fit alongside other material into a given size --
typically one or more CD-Rs.

It prints the maximum bitrate for following sizes (in MB): 185, 247,
650, 700, 1300, and 1400 which are two kinds of mini-CD-Rs and the
standard sizes for one or two 74 and 80 minute CD-Rs.  Alternativly
the desired target size(s) can be given as command line option.


Why yet another bitrate calculator?
-----------------------------------

Well, the scripts that came with MPlayer_, transcode_, and the like
haven't suited my needs anymore because they allow only one argument
for the bitrate of other material than the video stream.  Mostly this
is intended for one audio stream.  But with modern container formats
like Matroska_ it's possible to mux [#]_ several audio streams and
even other material like attachements into the file.

As I like to encode the audio streams with variable bit rates before
encoding the video in order to get a better quality/size ratio, I
needed something I can feed with the sizes of all extra material
instead of just *one* bitrate value.

.. [#] *muxing* is the process of combining audio and video into a
       container format.

Features
--------

The script has the following "highlights":

- takes one or more length of material in *hour*:*minute*:*seconds*
  format,
- takes one or more bitrate values which are acummulated,
- takes filename(s) and let the script take the file's size into
  account,
- and takes overhead of container format into account (given in
  percent).


Requirements
============

The script requires Python_ 2.3 or higher.  The 2.2 series (or lower)
won't work because it makes use of the new ``sum()`` function and the
included new option parser for more GNU like commandline arguments.


Commandline Options
===================

  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -bAUDIO_BITRATE, --audio-bitrate=AUDIO_BITRATE
                        Bitrate of audio stream.  Can be given several times
                        which means "add up all given bitrates".  If neither
                        this option nor any filename(s) were given, a value of
                        128 kbit/s is assumed.
  -fFPS, --fps=FPS      Frames per second for number of frames calculation.
                        Default = 25.0
  -oOVERHEAD, --container-overhead=OVERHEAD
                        Overhead of container format in %.  Default = 0.0. Every
                        container format has some overhead.  AVI and OGM have a
                        quite high one while Matroska is a very lean format.
                        The information on the net about the values varies a
                        bit.  AVI and OGM need a value between 1.0 and 1.5 here
                        and Matroska needs 0.5 or even a bit lower.
  -tSIZES, --target-sizes=SIZES
                        One or more comma separated target size(s) in MB.
                        Giving sizes here replaces the default list of [185,
                        247, 650, 700, 1300, 1400] MB


Good overhead values
--------------------

I have no idea what the best values are.  This depends sometimes on
the codec and the encoder of the material to be encoded.

For example some simplified math shows that the overhead of Matroska_
files is about 0.5%, but with transcode_ and a 2-pass encoded XviD_
video I get away with 0.0% all the time because the video becomes
always a little smaller than the bitrate given to the encoder implies.

.. rubric:: Need **your** help!

I would like to know *your* experience with the overhead values.  It
would be very nice if you are willing to share information about
typical overhead of *codec*, *encoder*, and *container format*
combinations.  Please `contact me`_.

.. _contact me: marc@rintsch.de

Examples
========

The simplest case is just providing the length of the stream and let
the script assume the audio to be 128 kbit/s::

  ./bitrate.py 1:42:23

With relative short material like episodes of TV series often two or
more videos fit on one target medium at a reasonable bitrate.  In this
case it is tedious to calculate the overall length by hand.  Therefore
it is possible to give several lengths, separated by commas::

  ./bitrate.py 42:23,40:17

The case which is described in `Why yet another bitrate calculator?`_
above, where the audio is already encoded in several variable bitrate
streams this time plus some subtitles in a Ogg media container::

  ./bitrate.py 42:23 sound-en.ogg sound-de.mp3 subtitles.ogm

A not so obvious use of the script is calculating the bitrate for a
sound track if you already have the encoded video.  Maybe you have
even both, the video and the audio already encoded but it turns out
that there are still some megabytes of free space on the target
medium.  You can of course re-encode the video with a slightly higher
bitrate now, but if the space is less than about 10 MB this takes very
long for just a tiny little quality gain which might not be visible at
all.  Re-encoding the audio with a little higher bitrate instead isn't
more likely to be noticable quality wise, but it's much faster and be
honest: a video file that fills the CD-R exactly to the last MB looks
better than leaving some megabytes free, doesn't it!?  ;-) ::

  ./bitrate.py 42:23 some-video.avi

Sometimes there's additional material to put onto the target medium so
the list of builtin target sizes won't do.  Therefore there is an
option to give one or more target sizes::

  ./bitrate.py --target-sizes 350,200 2:18:04


History
=======

0.3 : 2005-01-15
  Several length values that are added up and an option to replace the
  list of target sizes.  Some exceptions that could be raised while
  converting the command line options are catched.

0.2 : 2004-01-01
  Added calculation of number of frames, based on the length and a
  given framerate (``--fps``) and catched file errors to provide more
  userfriendly error messages.

0.1 : 2003-11-18
  Initial release.  Already calculates bitrates.  :-)


ToDo
====

- Move option parser code into own function.

- Add named constants to container overhead option.


Bugs
====

None known yet.


See also
========

The three most popular codecs and container formats.  Well sort of...

Video codecs (all MPEG4)
------------------------

DivX_
    The classic one.  Evil and *not free*.  Although *for* free -- at
    least the basic version.

XviD_
    The political correct one.  It's free as in free speech and at
    least as good as the basic version of DivX_.

ffmpeg_
    The fast one.  The ffmpeg package contains the fastest free MPEG4
    compliant encoder with reasonable quality.  The decoder is used by
    most video players to play MPEG4 under Linux.  The package is part
    of MPlayer_ and hosted on the same site.

There's also Ogg Theora but it's still beta software and not MPEG4
compliant.


Container formats
-----------------

_`AVI` : Audio/Video Interleaved
    The classic one.  As DivX_ it's evil.  Not just because it's an
    invention of `the evil empire`_ but because it has a rather high
    overhead.  MEncoder [#]_ and transcode_ support it out-of-the-box.

_`OGM` : OGg Media streams
    Somekind of half official hack of the Ogg Vorbis_ audio format.
    Like AVI_ it has a rather high overhead.  The format is, like it's
    audio ancestor, streamable.  One tool to mux video and audio into
    OGMs is ``ogmmerge`` from the ogmtools_.

_`MKV` : MatrosKa Video file
    Quite new in the arena.  It's based on some kind of binary XML
    format to keep it flexible for prospectively extensions.  It has
    very low overhead, which was a design goal and allows to embed
    arbitrary attachements. One tool to mux video and audio into MKVs
    is ``mkvmerge`` from the mkvtoolnix_ package or its graphical
    frontend ``mmg``.

.. [#] MEncoder is part of the MPlayer_ package.


Copyright
=========

Copyright © 2003-2005 Marc 'BlackJack' Rintsch <marc@rintsch.de>

This is free software; see the source for copying conditions. There is
NO warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.


.. _DivX: http://www.divx.com/
.. _MPlayer: http://www.MPlayerHQ.hu/
.. _Matroska: http://www.matroska.org/
.. _Python: http://www.python.org/
.. _Vorbis: http://www.vorbis.com/
.. _XviD: http://www.xvid.org/
.. _ffmpeg: http://www.MPlayerHQ.hu/
.. _the evil empire: http://www.micro$oft.com/
.. _transcode: http://www.transcoding.org/
.. _mkvtoolnix: http://www.bunkus.org/videotools/mkvtoolnix/
.. _ogmtools: http://www.bunkus.org/videotools/ogmtools/
