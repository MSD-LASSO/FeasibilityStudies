#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Filter Sig
# GNU Radio version: 3.7.13.5
##################################################

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print "Warning: failed to XInitThreads()"

from gnuradio import analog
from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import gr
from gnuradio import wxgui
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from gnuradio.wxgui import scopesink2
from grc_gnuradio import wxgui as grc_wxgui
from optparse import OptionParser
import pmt
import wx


class filter_sig(grc_wxgui.top_block_gui):

    def __init__(self, cutoff_freq=12000, decimation=1, num_samples=10000000, samp_rate=2000000, save_file='', source_file='', trans_width=2000):
        grc_wxgui.top_block_gui.__init__(self, title="Filter Sig")
        _icon_path = "C:\Program Files\GNURadio-3.7\share\icons\hicolor\scalable/apps\gnuradio-grc.png"
        self.SetIcon(wx.Icon(_icon_path, wx.BITMAP_TYPE_ANY))

        ##################################################
        # Parameters
        ##################################################
        self.cutoff_freq = cutoff_freq
        self.decimation = decimation
        self.num_samples = num_samples
        self.samp_rate = samp_rate
        self.save_file = save_file
        self.source_file = source_file
        self.trans_width = trans_width

        ##################################################
        # Blocks
        ##################################################
        self.wxgui_scopesink2_0 = scopesink2.scope_sink_f(
        	self.GetWin(),
        	title='Scope Plot',
        	sample_rate=samp_rate,
        	v_scale=0,
        	v_offset=0,
        	t_scale=0,
        	ac_couple=False,
        	xy_mode=False,
        	num_inputs=1,
        	trig_mode=wxgui.TRIG_MODE_AUTO,
        	y_axis_label='Counts',
        )
        self.Add(self.wxgui_scopesink2_0.win)
        self.blocks_throttle_0 = blocks.throttle(gr.sizeof_gr_complex*1, samp_rate,True)
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_vff((2, ))
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_gr_complex*1, 'C:\\Users\\devri\\Documents\\RIT\\Sixth Semester\\MSD I\\GIT\\readInData\\initialDemo\\filteredData\\pi_1_ref_sig_filtered_3', True)
        self.blocks_file_source_0.set_begin_tag(pmt.PMT_NIL)
        self.analog_wfm_rcv_0 = analog.wfm_rcv(
        	quad_rate=2e6,
        	audio_decimation=1,
        )



        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_wfm_rcv_0, 0), (self.blocks_multiply_const_vxx_0, 0))
        self.connect((self.blocks_file_source_0, 0), (self.blocks_throttle_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.wxgui_scopesink2_0, 0))
        self.connect((self.blocks_throttle_0, 0), (self.analog_wfm_rcv_0, 0))

    def get_cutoff_freq(self):
        return self.cutoff_freq

    def set_cutoff_freq(self, cutoff_freq):
        self.cutoff_freq = cutoff_freq

    def get_decimation(self):
        return self.decimation

    def set_decimation(self, decimation):
        self.decimation = decimation

    def get_num_samples(self):
        return self.num_samples

    def set_num_samples(self, num_samples):
        self.num_samples = num_samples

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.wxgui_scopesink2_0.set_sample_rate(self.samp_rate)
        self.blocks_throttle_0.set_sample_rate(self.samp_rate)

    def get_save_file(self):
        return self.save_file

    def set_save_file(self, save_file):
        self.save_file = save_file

    def get_source_file(self):
        return self.source_file

    def set_source_file(self, source_file):
        self.source_file = source_file

    def get_trans_width(self):
        return self.trans_width

    def set_trans_width(self, trans_width):
        self.trans_width = trans_width


def argument_parser():
    parser = OptionParser(usage="%prog: [options]", option_class=eng_option)
    parser.add_option(
        "", "--cutoff-freq", dest="cutoff_freq", type="intx", default=12000,
        help="Set cutoff_freq [default=%default]")
    parser.add_option(
        "", "--decimation", dest="decimation", type="intx", default=1,
        help="Set decimation [default=%default]")
    parser.add_option(
        "", "--num-samples", dest="num_samples", type="intx", default=10000000,
        help="Set num_samples [default=%default]")
    parser.add_option(
        "", "--samp-rate", dest="samp_rate", type="intx", default=2000000,
        help="Set samp_rate [default=%default]")
    parser.add_option(
        "", "--save-file", dest="save_file", type="string", default='',
        help="Set save_file [default=%default]")
    parser.add_option(
        "", "--source-file", dest="source_file", type="string", default='',
        help="Set source_file [default=%default]")
    parser.add_option(
        "", "--trans-width", dest="trans_width", type="intx", default=2000,
        help="Set trans_width [default=%default]")
    return parser


def main(top_block_cls=filter_sig, options=None):
    if options is None:
        options, _ = argument_parser().parse_args()

    tb = top_block_cls(cutoff_freq=options.cutoff_freq, decimation=options.decimation, num_samples=options.num_samples, samp_rate=options.samp_rate, save_file=options.save_file, source_file=options.source_file, trans_width=options.trans_width)
    tb.Start(True)
    tb.Wait()


if __name__ == '__main__':
    main()
