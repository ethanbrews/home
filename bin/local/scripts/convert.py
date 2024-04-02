import argparse
from os import path
from subprocess import run

converters = {
    'pandoc': {
        'commandline': '{executable} {inFile} --output {outFile}',
        'inTypes': ['.creole', '.djot', '.xml', '.docbook', '.epub', '.fb2', '.hs', '.html,', '.htm', '.txt', '.xml', '.json', '.tex', '.md', '.1', '.2', '.3', '.markdown', '.odt', '.opml', '.docx', '.org', '.rst', '.textile', '.t2t', '.wiki'],
        'outTypes': ['.js', '.epub', '.org', '.rst', '.1', '.markdown', '.xml', '.icml', '.pptx', '.adoc', '.html', '.txt', '.djot', '.docbook', '.hs', '.3', '.odt', '.rtf', '.tex', '.asciidoc', '.texi', '.textile', '.wiki', '.opml', '.pdf', '.json', '.2', '.htm', '.md', '.docx', '.fb2']
    },
    'ffmpeg': {
        'commandline': '{executable} -i {inFile} {outFile}',
        'inTypes': ['3dostr', '4xm', 'aa', 'aac', 'aax', 'ac3', 'ac4', 'ace', 'acm', 'act', 'adf', 'adp', 'ads', 'adx', 'aea', 'afc', 'aiff', 'aix', 'alaw', 'alias_pix', 'alp', 'amr', 'amrnb', 'amrwb', 'anm', 'apac', 'apc', 'ape', 'apm', 'apng', 'aptx', 'aptx_hd', 'aqtitle', 'argo_asf', 'argo_brp', 'argo_cvg', 'asf', 'asf_o', 'ass', 'ast', 'au', 'av1', 'avi', 'avisynth', 'avr', 'avs', 'avs2', 'avs3', 'bethsoftvid', 'bfi', 'bfstm', 'bin', 'bink', 'binka', 'bit', 'bitpacked', 'bmp_pipe', 'bmv', 'boa', 'bonk', 'brender_pix', 'brstm', 'c93', 'caf', 'cavsvideo', 'cdg', 'cdxl', 'cine', 'codec2', 'codec2raw', 'concat', 'cri_pipe', 'dash', 'data', 'daud', 'dcstr', 'dds_pipe', 'derf', 'dfa', 'dfpwm', 'dhav', 'dirac', 'dnxhd', 'dpx_pipe', 'dsf', 'dshow', 'dsicin', 'dss', 'dts', 'dtshd', 'dv', 'dvbsub', 'dvbtxt', 'dxa', 'ea', 'ea_cdata', 'eac3', 'epaf', 'evc', 'exr_pipe', 'f32be', 'f32le', 'f64be', 'f64le', 'ffmetadata', 'film_cpk', 'filmstrip', 'fits', 'flac', 'flic', 'flv', 'frm', 'fsb', 'fwse', 'g722', 'g723_1', 'g726', 'g726le', 'g729', 'gdigrab', 'gdv', 'gem_pipe', 'genh', 'gif', 'gif_pipe', 'gsm', 'gxf', 'h261', 'h263', 'h264', 'hca', 'hcom', 'hdr_pipe', 'hevc', 'hls', 'hnm', 'ico', 'idcin', 'idf', 'iff', 'ifv', 'ilbc', 'image2', 'image2pipe', 'imf', 'ingenient', 'ipmovie', 'ipu', 'ircam', 'iss', 'iv8', 'ivf', 'ivr', 'j2k_pipe', 'jacosub', 'jpeg_pipe', 'jpegls_pipe', 'jpegxl_anim', 'jpegxl_pipe', 'jv', 'kux', 'kvag', 'laf', 'lavfi', 'libcdio', 'libgme', 'libmodplug', 'libopenmpt', 'live_flv', 'lmlm4', 'loas', 'lrc', 'luodat', 'lvf', 'lxf', 'm4v', 'matroska,webm', 'mca', 'mcc', 'mgsts', 'microdvd', 'mjpeg', 'mjpeg_2000', 'mlp', 'mlv', 'mm', 'mmf', 'mods', 'moflex', 'mov,mp4,m4a,3gp,3g2,mj2', 'mp3', 'mpc', 'mpc8', 'mpeg', 'mpegts', 'mpegtsraw', 'mpegvideo', 'mpjpeg', 'mpl2', 'mpsub', 'msf', 'msnwctcp', 'msp', 'mtaf', 'mtv', 'mulaw', 'musx', 'mv', 'mvi', 'mxf', 'mxg', 'nc', 'nistsphere', 'nsp', 'nsv', 'nut', 'nuv', 'obu', 'ogg', 'oma', 'osq', 'paf', 'pam_pipe', 'pbm_pipe', 'pcx_pipe', 'pdv', 'pfm_pipe', 'pgm_pipe', 'pgmyuv_pipe', 'pgx_pipe', 'phm_pipe', 'photocd_pipe', 'pictor_pipe', 'pjs', 'pmp', 'png_pipe', 'pp_bnk', 'ppm_pipe', 'psd_pipe', 'psxstr', 'pva', 'pvf', 'qcp', 'qdraw_pipe', 'qoi_pipe', 'r3d', 'rawvideo', 'realtext', 'redspark', 'rka', 'rl2', 'rm', 'roq', 'rpl', 'rsd', 'rso', 'rtp', 'rtsp', 's16be', 's16le', 's24be', 's24le', 's32be', 's32le', 's337m', 's8', 'sami', 'sap', 'sbc', 'sbg', 'scc', 'scd', 'sdns', 'sdp', 'sdr2', 'sds', 'sdx', 'ser', 'sga', 'sgi_pipe', 'shn', 'siff', 'simbiosis_imx', 'sln', 'smjpeg', 'smk', 'smush', 'sol', 'sox', 'spdif', 'srt', 'stl', 'subviewer', 'subviewer1', 'sunrast_pipe', 'sup', 'svag', 'svg_pipe', 'svs', 'swf', 'tak', 'tedcaptions', 'thp', 'tiertexseq', 'tiff_pipe', 'tmv', 'truehd', 'tta', 'tty', 'txd', 'ty', 'u16be', 'u16le', 'u24be', 'u24le', 'u32be', 'u32le', 'u8', 'usm', 'v210', 'v210x', 'vag', 'vbn_pipe', 'vc1', 'vc1test', 'vfwcap', 'vidc', 'vividas', 'vivo', 'vmd', 'vobsub', 'voc', 'vpk', 'vplayer', 'vqf', 'vvc', 'w64', 'wady', 'wav', 'wavarc', 'wc3movie', 'webm_dash_manifest', 'webp_pipe', 'webvtt', 'wsaud', 'wsd', 'wsvqa', 'wtv', 'wv', 'wve', 'xa', 'xbin', 'xbm_pipe', 'xmd', 'xmv', 'xpm_pipe', 'xvag', 'xwd_pipe', 'xwma', 'yop', 'yuv4mpegpipe'],
        'outTypes': ['3g2', '3gp', 'a64', 'ac3', 'ac4', 'adts', 'adx', 'aiff', 'alaw', 'alp', 'amr', 'amv', 'apm', 'apng', 'aptx', 'aptx_hd', 'argo_asf', 'argo_cvg', 'asf', 'asf_stream', 'ass', 'ast', 'au', 'avi', 'avif', 'avm2', 'avs2', 'avs3', 'bit', 'caca', 'caf', 'cavsvideo', 'chromaprint', 'codec2', 'codec2raw', 'crc', 'dash', 'data', 'daud', 'dfpwm', 'dirac', 'dnxhd', 'dts', 'dv', 'dvd', 'eac3', 'evc', 'f32be', 'f32le', 'f4v', 'f64be', 'f64le', 'ffmetadata', 'fifo', 'fifo_test', 'film_cpk', 'filmstrip', 'fits', 'flac', 'flv', 'framecrc', 'framehash', 'framemd5', 'g722', 'g723_1', 'g726', 'g726le', 'gif', 'gsm', 'gxf', 'h261', 'h263', 'h264', 'hash', 'hds', 'hevc', 'hls', 'ico', 'ilbc', 'image2', 'image2pipe', 'ipod', 'ircam', 'ismv', 'ivf', 'jacosub', 'kvag', 'latm', 'lrc', 'm4v', 'matroska', 'md5', 'microdvd', 'mjpeg', 'mkvtimestamp_v2', 'mlp', 'mmf', 'mov', 'mp2', 'mp3', 'mp4', 'mpeg', 'mpeg1video', 'mpeg2video', 'mpegts', 'mpjpeg', 'mulaw', 'mxf', 'mxf_d10', 'mxf_opatom', 'null', 'nut', 'obu', 'oga', 'ogg', 'ogv', 'oma', 'opus', 'psp', 'rawvideo', 'rm', 'roq', 'rso', 'rtp', 'rtp_mpegts', 'rtsp', 's16be', 's16le', 's24be', 's24le', 's32be', 's32le', 's8', 'sap', 'sbc', 'scc', 'sdl,sdl2', 'segment', 'smjpeg', 'smoothstreaming', 'sox', 'spdif', 'spx', 'srt', 'stream_segment,ssegment', 'streamhash', 'sup', 'svcd', 'swf', 'tee', 'truehd', 'tta', 'ttml', 'u16be', 'u16le', 'u24be', 'u24le', 'u32be', 'u32le', 'u8', 'uncodedframecrc', 'vc1', 'vc1test', 'vcd', 'vidc', 'vob', 'voc', 'vvc', 'w64', 'wav', 'webm', 'webm_chunk', 'webm_dash_manifest', 'webp', 'webvtt', 'wsaud', 'wtv', 'wv', 'yuv4mpegpipe']
    },
    'magick': {
        'commandline': '{executable} {inFile} {outFile}',
        'inTypes': ['.aai', '.apng', '.art', '.arw', '.avi', '.avif', '.avs', '.bayer', '.bpg', '.bmp, bmp2, bmp3', '.cals', '.cin', '.cmyk', '.cmyka', '.cr2', '.crw', '.cube', '.cur', '.cut', '.dcm', '.dcr', '.dcx', '.dds', '.dib', '.djvu', '.dmr', '.dng', '.dot', '.dpx', '.emf', '.epdf', '.epi', '.eps', '.epsf', '.epsi', '.ept', '.exr', '.farbfeld', '.fax', '.fits', '.fl32', '.flif', '.fpx', '.ftxt', '.gif', '.gplt', '.gray', '.graya', '.hdr', '.hdr', '.heic', '.hpgl', '.hrz', '.html', '.ico', '.jbig', '.jng', '.jp2', '.jpt', '.j2c', '.j2k', '.jpeg', '.jxr', '.jxl', '.man', '.mat', '.miff', '.mono', '.mng', '.m2v', '.mpeg', '.mpc', '.mpo', '.mpr', '.mrw', '.msl', '.mtv', '.mvg', '.nef', '.orf', '.ora', '.otb', '.p7', '.palm', '.clipboard', '.pbm', '.pcd', '.pcds', '.pcx', '.pdb', '.pdf', '.pef', '.pes', '.pfa', '.pfb', '.pfm', '.pgm', '.phm', '.picon', '.pict', '.pix', '.png', '.png8', '.png00', '.png24', '.png32', '.png48', '.png64', '.pnm', '.pocketmod', '.ppm', '.ps', '.ps2', '.ps3', '.psb', '.psd', '.ptif', '.pwp', '.qoi', '.rad', '.raf', '.raw', '.rgb', '.rgb565', '.rgba', '.rgf', '.rla', '.rle', '.sct', '.sfw', '.sgi', '.sid, mrsid', '.strimg', '.sun', '.svg', '.text', '.tga', '.tiff', '.tim', '.ttf', '.txt', '.uhdr', '.uyvy', '.vicar', '.video', '.viff', '.wbmp', '.wdp', '.webp', '.wmf', '.wpg', '.x', '.xbm', '.xcf', '.xpm', '.xwd', '.x3f', '.ycbcr', '.ycbcra', '.yuv'],
        'outTypes': ['aai', 'apng', 'art', 'avif', 'avs', 'bayer', 'bpg', 'bmp, bmp2, bmp3', 'brf', 'cin', 'cip', 'cmyk', 'cmyka', 'dcx', 'dds', 'debug', 'dib', 'dmr', 'dpx', 'epdf', 'epi', 'eps', 'eps2', 'eps3', 'epsf', 'epsi', 'ept', 'exr', 'farbfeld', 'fax', 'fits', 'fl32', 'flif', 'fpx', 'ftxt', 'gif', 'gray', 'graya', 'hdr', 'hdr', 'heic', 'hrz', 'html', 'info', 'isobrl', 'isobrl6', 'jbig', 'jng', 'jp2', 'jpt', 'j2c', 'j2k', 'jpeg', 'jxr', 'json', 'jxl', 'kernel', 'miff', 'mono', 'mng', 'm2v', 'mpeg', 'mpc', 'mpr', 'msl', 'mtv', 'mvg', 'otb', 'p7', 'palm', 'pam', 'clipboard', 'pbm', 'pcd', 'pcds', 'pcl', 'pcx', 'pdb', 'pdf', 'pfm', 'pgm', 'phm', 'picon', 'pict', 'png', 'png8', 'png00', 'png24', 'png32', 'png48', 'png64', 'pnm', 'pocketmod', 'ppm', 'ps', 'ps2', 'ps3', 'psb', 'psd', 'ptif', 'qoi', 'raw', 'rgb', 'rgba', 'rgf', 'sgi', 'shtml', 'sparse-color', 'strimg', 'sun', 'svg', 'tga', 'tiff', 'txt', 'ubrl', 'ubrl6', 'uhdr', 'uil', 'uyvy', 'vicar', 'video', 'viff', 'wbmp', 'wdp', 'webp', 'x', 'xbm', 'xpm', 'xwd', 'yaml', 'ycbcr', 'ycbcra', 'yuv']
    }
}

def find_matching_converter(in_type, out_type):
    matching_converters = filter(lambda conv: in_type in conv[1]['inTypes'] and out_type in conv[1]['outTypes'], converters.items())
    return next(iter(matching_converters), None)[0]

def convert(in_file, out_file):
    _, in_ext = path.splitext(in_file)
    _, out_ext = path.splitext(out_file)
    converter = find_matching_converter(in_ext, out_ext)

    command = converters[converter]['commandline'].format(executable=converter, inFile=in_file, outFile=out_file)
    return command

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='convert',
        description='Detect filetypes and convert documents using other tools',
        epilog=f'Depends on: {", ".join(converters.keys())}'
    )
    parser.add_argument('inFile', type=str)
    parser.add_argument('outFile', type=str)
    parser.add_argument('--preview', action='store_true')
    args = parser.parse_args()
    if args.inFile is None:
        raise ValueError('No inFile was provided')
    if args.outFile is None:
        raise ValueError('No outFile was provided')
    cmd = convert(args.inFile, args.outFile)
    print(cmd)
    if not args.preview:
        run(cmd, shell=True)
