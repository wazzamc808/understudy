//
//  Copyright 2010 Kirk Kelsey.
//
//  This file is part of Understudy.
//
//  Understudy is free software: you can redistribute it and/or modify it under
//  the terms of the GNU Lesser General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  Understudy is distributed in the hope that it will be useful, but WITHOUT 
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
//  for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with Understudy.  If not, see <http://www.gnu.org/licenses/>.

#import <CoreAudio/CoreAudio.h>

#import "UNDVolumeControl.h"

void
changeVolume (float delta)
{
  
  OSStatus           err;
  AudioDeviceID      device;
  UInt32             size;
  UInt32             channels[2];
  float              involume;
  
  size = sizeof (device);
  err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice,
                                 &size,
                                 &device);
  if (err!=noErr) {
    NSLog (@"error getting audio device reference");
    return;
  }
  
  if (err==noErr) {
    size = sizeof involume;
    err = AudioDeviceGetProperty(device,
                                 0,
                                 false,
                                 kAudioDevicePropertyVolumeScalar,
                                 &size,
                                 &involume);  
  }
  if (err==noErr) {
    involume += delta;
    size = sizeof (involume);
    err = AudioDeviceSetProperty (device,
                                  NULL,
                                  0,
                                  false,
                                  kAudioDevicePropertyVolumeScalar,
                                  size,
                                  &involume);
    return;
  }
  
  // get channels
  size = sizeof(channels);
  err = AudioDeviceGetProperty(device,
                               0,
                               false,
                               kAudioDevicePropertyPreferredChannelsForStereo,
                               &size,
                               &channels);
  if (err!=noErr) {
    NSLog(@"error getting channel-numbers");
    return;
  }
  
  // get volume
  size = sizeof (involume);
  err = AudioDeviceGetProperty(device,
                               channels[0],
                               false,
                               kAudioDevicePropertyVolumeScalar,
                               &size,
                               &involume);
  involume += delta;
  size = sizeof (involume);
  err = AudioDeviceSetProperty(device,
                               0,
                               channels[0],
                               false,
                               kAudioDevicePropertyVolumeScalar,
                               size,
                               &involume);
  if(noErr!=err) NSLog(@"error setting volume of channel %d",channels[0]);
  
  err = AudioDeviceGetProperty(device,
                               channels[1],
                               false,
                               kAudioDevicePropertyVolumeScalar,
                               &size,
                               &involume);
  involume += delta;
  size = sizeof (involume);
  err = AudioDeviceSetProperty(device,
                               0,
                               channels[1],
                               false,
                               kAudioDevicePropertyVolumeScalar,
                               size,
                               &involume);
  if(noErr!=err) NSLog(@"error setting volume of channel %d",channels[1]);
}