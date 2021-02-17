#!/usr/bin/env python
from demo_waveform_plot import get_waveform_plot, set_xlabels_sample2time
import matplotlib.pyplot as plt
from numpy import array, ma
import numpy as np
import os.path
from aubio import source, pitch

import socket
import json


HOST = '127.0.0.1'  # The server's hostname or IP address
PORT = 65432        # The port used by the server

filename = "./scale.wav"

downsample = 1
samplerate = 44100 // downsample

win_s = 4096 // downsample  # fft size
hop_s = 512 // downsample  # hop size

s = source(filename, samplerate, hop_s)
samplerate = s.samplerate

tolerance = 0.8

pitch_o = pitch("yinfast", win_s, hop_s, samplerate)
pitch_o.set_unit("midi")
pitch_o.set_tolerance(tolerance)

pitches = []
confidences = []

# total number of frames read
total_frames = 0
while True:
    samples, read = s()
    pitch = pitch_o(samples)[0]
    #pitch = int(round(pitch))
    confidence = pitch_o.get_confidence()
    #if confidence < 0.8: pitch = 0.
    #print("%f %f %f" % (total_frames / float(samplerate), pitch, confidence))
    pitches += [pitch]
    confidences += [confidence]
    total_frames += read    
    if read < hop_s:
        break

pitches1 = np.array(pitches).tolist()
pitches2 = json.dumps({"pitcharray":pitches1})

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    s.sendall(pitches2.encode('utf-8'))
    data = s.recv(1024)


skip = 1

pitches = array(pitches[skip:])
data = array(data[skip:])
confidences = array(confidences[skip:])
times = [t * hop_s for t in range(len(pitches))]

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        s.sendmsg(data)
        data = s.recv(1024)
        print(1)


def array_from_text_file(filename, dtype='float'):
    filename = os.path.join(os.path.dirname(__file__), filename)
    return array([line.split() for line in open(filename).readlines()],
                 dtype=dtype)

