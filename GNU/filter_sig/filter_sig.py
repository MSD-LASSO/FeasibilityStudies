#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Filter Sig
# GNU Radio version: 3.7.13.5
##################################################

from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser
import pmt


class filter_sig(gr.top_block):

    def __init__(self, cutoff_freq=12000, decimation=1, num_samples=10000000, samp_rate=20000000, save_file='', source_file='', trans_width=2000):
        gr.top_block.__init__(self, "Filter Sig")

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
        self.low_pass_filter_0_1 = filter.fir_filter_ccf(decimation, firdes.low_pass(
        	1, samp_rate, cutoff_freq, trans_width, firdes.WIN_HAMMING, 6.76))
        self.blocks_throttle_0 = blocks.throttle(gr.sizeof_gr_complex*1, samp_rate,True)
        self.blocks_head_0 = blocks.head(gr.sizeof_gr_complex*1, num_samples)
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_gr_complex*1, source_file, True)
        self.blocks_file_source_0.set_begin_tag(pmt.PMT_NIL)
        self.blocks_file_sink_1 = blocks.file_sink(gr.sizeof_gr_complex*1, save_file, False)
        self.blocks_file_sink_1.set_unbuffered(False)



        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_file_source_0, 0), (self.blocks_throttle_0, 0))
        self.connect((self.blocks_head_0, 0), (self.blocks_file_sink_1, 0))
        self.connect((self.blocks_throttle_0, 0), (self.low_pass_filter_0_1, 0))
        self.connect((self.low_pass_filter_0_1, 0), (self.blocks_head_0, 0))

    def get_cutoff_freq(self):
        return self.cutoff_freq

    def set_cutoff_freq(self, cutoff_freq):
        self.cutoff_freq = cutoff_freq
        self.low_pass_filter_0_1.set_taps(firdes.low_pass(1, self.samp_rate, self.cutoff_freq, self.trans_width, firdes.WIN_HAMMING, 6.76))

    def get_decimation(self):
        return self.decimation

    def set_decimation(self, decimation):
        self.decimation = decimation

    def get_num_samples(self):
        return self.num_samples

    def set_num_samples(self, num_samples):
        self.num_samples = num_samples
        self.blocks_head_0.set_length(self.num_samples)

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.low_pass_filter_0_1.set_taps(firdes.low_pass(1, self.samp_rate, self.cutoff_freq, self.trans_width, firdes.WIN_HAMMING, 6.76))
        self.blocks_throttle_0.set_sample_rate(self.samp_rate)

    def get_save_file(self):
        return self.save_file

    def set_save_file(self, save_file):
        self.save_file = save_file
        self.blocks_file_sink_1.open(self.save_file)

    def get_source_file(self):
        return self.source_file

    def set_source_file(self, source_file):
        self.source_file = source_file
        self.blocks_file_source_0.open(self.source_file, True)

    def get_trans_width(self):
        return self.trans_width

    def set_trans_width(self, trans_width):
        self.trans_width = trans_width
        self.low_pass_filter_0_1.set_taps(firdes.low_pass(1, self.samp_rate, self.cutoff_freq, self.trans_width, firdes.WIN_HAMMING, 6.76))


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
        "", "--samp-rate", dest="samp_rate", type="intx", default=20000000,
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
    tb.start()
    tb.wait()


if __name__ == '__main__':
    main()
