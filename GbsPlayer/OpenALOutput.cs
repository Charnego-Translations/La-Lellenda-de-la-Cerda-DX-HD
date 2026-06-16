using System;
using System.Collections.Generic;
using Microsoft.Xna.Framework.Audio;

namespace GbsPlayer
{
    public class OpenALOutput : IAudioOutput
    {
        private DynamicSoundEffectInstance _dynamicSound;
        private Queue<byte[]> _bufferQueue = new Queue<byte[]>();
        private object _bufferLock = new object();
        private int _sampleRate;
        private SoundState _state = SoundState.Stopped;

        public SoundState State => _state;

        public OpenALOutput(int sampleRate)
        {
            _sampleRate = sampleRate;
            _dynamicSound = new DynamicSoundEffectInstance(sampleRate, AudioChannels.Mono);
            _dynamicSound.BufferNeeded += OnBufferNeeded;
        }

        public int GetPendingBufferCount()
        {
            lock (_bufferLock)
            {
                return _bufferQueue.Count;
            }
        }

        public void Play()
        {
            lock (_bufferLock)
            {
                _state = SoundState.Playing;
                _dynamicSound.Play();
            }
        }

        public void Pause()
        {
            lock (_bufferLock)
            {
                _state = SoundState.Paused;
                _dynamicSound.Pause();
            }
        }

        public void Resume()
        {
            lock (_bufferLock)
            {
                _state = SoundState.Playing;
                _dynamicSound.Resume();
            }
        }

        public void Stop()
        {
            lock (_bufferLock)
            {
                _state = SoundState.Stopped;
                _dynamicSound.Stop();
                lock (_bufferQueue)
                    _bufferQueue.Clear();
            }
        }

        public void SetVolume(float volume)
        {
            _dynamicSound.Volume = volume;
        }

        public void SubmitBuffer(byte[] buffer, int offset, int count)
        {
            var copy = new byte[count];
            Buffer.BlockCopy(buffer, offset, copy, 0, count);

            lock (_bufferLock)
            {
                if (_dynamicSound.PendingBufferCount < 3)
                    _dynamicSound.SubmitBuffer(copy, 0, count);
                else
                    _bufferQueue.Enqueue(copy);
            }
        }

        private void OnBufferNeeded(object sender, EventArgs e)
        {
            lock (_bufferLock)
            {
                while (_dynamicSound.PendingBufferCount < 3 && _bufferQueue.Count > 0)
                {
                    var buffer = _bufferQueue.Dequeue();
                    _dynamicSound.SubmitBuffer(buffer, 0, buffer.Length);
                }
            }
        }
    }
}
