#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Name:        bitrate.py
# Purpose:     Some functions to calculate bitrates + command line app.
#
# Author:      Marc 'BlackJack' Rintsch
#
# Created:     2003-11-09
# Copyright:   (c) 2003-2005
# Licence:     GPL
#-----------------------------------------------------------------------------
"""Functions to calculate bitrates.

The unit *kbit/s* is 1000 bits per second.  The prefix *k* does not mean
1024 as often used in KB = 1024 bytes or MB = 1024*1024 bytes.

:todo: Document exceptions and return values.

:todo: Maybe insert more examples into docstrings.

:todo: Refactor `main()`.  Too many local variables, so things have to be
       moved to subfunctions.

:todo: Add list of times and list of integers as types to optionparser.
"""

__version__ = '0.3'
__date__ = '2005-01-15'
__author__ = "Marc 'BlackJack' Rintsch"
__credits__ = 'The authors of transcode for an excellent movie transcoder.'

__docformat__ = "reStructuredText"


def bitrate2bytes(bitrate, length):
    """Calculates the number of bytes from `bitrate` and `length`.
    
    :param bitrate: bitrate in kbit/s.
    :param length: length in seconds.
    
    :returns: number of bytes at given `bitrate` and `length`
    
    :see: `bytes2bitrate()`
    """
    return (bitrate * length * 1000) / 8.0


def bytes2bitrate(size, length):
    """Calculates the the bitrate from number of bytes and length.
    
    :param size: size in bytes.
    :param length: length in seconds.
    
    :returns: the bitrate of `size` bytes and `length` seconds.
    :rtype: float
    
    :see: `bitrate2bytes()`
    """
    assert length > 0
    return float(size * 8) / length / 1000


def calc_bitrate(targetsize, othersize, length, container_overhead=0.0):
    """Calculates the highest bitrate usable for `targetsize` if there
    already is `othersize` worth of data.
    
    :param targetsize: size of the target (e.g. CDs) in bytes.
    :param othersize: size of data (e.g. sound) that has to fit along
                      with the data we want to know the bitrate for,
                      in bytes.
    :param length: length in seconds.
    :param container_overhead: take that much percent of overhead from
                               the container format (e.g. AVI, OGM, MKV...)
                               into account.
    :type container_overhead: float
    
    :returns: the bitrate
    """
    overhead = 1.0 + (container_overhead / 100.0)
    size = (targetsize - othersize) / overhead
    return bytes2bitrate(size, length)


def parse_length(length):
    """Parses a length given as string and returns the number of seconds.
    
    Hours (<h>), minutes (<m>) and seconds (<s>) are not restricted,
    i.e. '2:198:2' is a legal length (== 2 hours + 198 minutes + 2 seconds).

    Examples::
        
      >>> parse_length('10')
      10
      >>> parse_length('725')
      725
      >>> parse_length('10:05')
      605
      >>> parse_length('104:03')
      6243
      >>> parse_length('1:0:0')
      3600

    :param length: length as string in format [<h>':'[<m>':']]<s>.
    :type length: str
    
    :returns: number of seconds expressed by `length`.
    :rtype: int
    
    :raises ValueError: if one of the components <h>, <m> or <s> cannot
        be converted to an integer.
    
    :see: `parse_lengths()`
    """
    result = 0
    multiplier = 1
    hms = length.split(':')
    hms.reverse()
    try:
        for component in hms:
            result += int(component) * multiplier
            multiplier *= 60
    except ValueError:
        raise ValueError("invalid length: %s" % length)
    
    return result


def parse_lengths(lengths):
    """Parses a list of comma separated lengths given as string to overall
    number of seconds.

    Examples::
    
      >>> parse_lengths('10:05, 1:00:00, 20')
      4225
      >>> parse_lengths('10:05')
      605

    :param lengths: list of lengths in format [<h>':'[<m>':']]<s> separated
                    by commas.
    :type lengths: str

    :returns: number of seconds of all `lengths` added up.
    :rtype: int
    
    :raises ValueError: if one of the lengths contains something not
        convertable to an integer.
    
    :see: `parse_length()`
    """
    return sum(map(parse_length, lengths.split(',')))
    

def main():
    """Use option -h for usage info."""
    import sys
    import os
    from optparse import OptionParser

    # A couple of target sizes in MB.
    sizes = [185, 247, 650, 700, 1300, 1400]

    # TODO: Overhead relative to AVI.
    #overheads = { 'none':0.0, 'avi':1.0, 'ogm':1.5, 'mkv':0.0 }
    
    length = 0      # Length in seconds.
    othersize = 0   # Size of other material in bytes.
    overhead = 0    # Overhead imposed by the container format.
    fps = 0         # Frames per second.
    
    # TODO: Move option parsing into own (private) function.
    usage_text = '''usage: %prog [options] length(s) [file ...]

The length argument has '[[<hours>:]<minutes>:]<seconds>' format. Every
value may "overflow" i.e. it's okay to type ``1:90:0`` which is actually
2 hours and a half.  Additional lengths, separated by commas, are added
to one final length.

The given files' sizes are taken into account when calculating the bitrate.'''

    parser = OptionParser(usage=usage_text, version='%%prog %s' % __version__)
    parser.add_option('-b', '--audio-bitrate', action='append', type='int',
                      dest='audio_bitrate', default=list(),
                      help='Bitrate of audio stream.  Can be given several '
                      'times which means "add up all given bitrates".  If '
                      'neither this option nor any filename(s) were given, '
                      'a value of 128 kbit/s is assumed.')
    parser.add_option('-f', '--fps', type='float', dest='fps', default=25,
                      help='Frames per second for number of frames '
                      'calculation. Default = 25.0')
    parser.add_option('-o', '--container-overhead', type='string',
                      dest='overhead', default=0,
                      help='''Overhead of container format in %.  Default = 0.0.
Every container format has some overhead.  AVI and OGM have a quite high one
while Matroska is a very lean format.  The information on the net about
the values varies a bit.  AVI and OGM need a value between 1.0 and 1.5 here
and Matroska needs 0.5 or even a bit lower.''')
    parser.add_option('-t', '--target-sizes', type='string', action='store',
                      dest='sizes', default=list(),
                      help='''One or more comma separated target size(s) in MB.
                      Giving sizes here replaces the default list of %r MB'''
                      % sizes)
    
    (options, args) = parser.parse_args()

    try:
        # If length is not given on command line then print help.
        if not args:
            parser.print_help()
            sys.exit()
        
        files = args[1:]
        
        try:
            length = parse_lengths(args[0])

            if options.sizes:
                sizes = map(int, options.sizes.split(','))

            overhead = float(options.overhead)
            fps = options.fps

        except ValueError, error:
            parser.print_usage()
            print error
            sys.exit()
        
        
        # If no bitrate or files where given on the command line
        # assume 128 kbit/s for other data.
        if not options.audio_bitrate and len(args) < 2:
            options.audio_bitrate = [128]
        
        othersize = (bitrate2bytes(sum(options.audio_bitrate), length)
                     + sum([os.stat(other_file).st_size
                            for other_file in files]))
        
        print ('Length: %d seconds (%d frames @ %.1f fps)\n'
               ' Other: %.2f MB @ %.1f kbit/s'
               % (length,
                  fps * length + 0.5,
                  fps,
                  othersize / float(1024*1024),
                  bytes2bitrate(othersize, length)))
        
        fmt = 'Target:%5d MB => %6.1f MB @ %.1f kbit/s'
        
        def func(size):
            """Build tuple suitable for format string `fmt` above."""
            bytes = size * 1024 * 1024
            return (size,
                    float(bytes - othersize) / (1024*1024),
                    calc_bitrate(bytes, othersize, length, overhead))
        
        print '\n'.join([fmt % values for values in map(func, sizes)
                         if values[1] > 0])
    
    except OSError, error:
        parser.print_usage()
        print error


if __name__ == '__main__':
    main()
