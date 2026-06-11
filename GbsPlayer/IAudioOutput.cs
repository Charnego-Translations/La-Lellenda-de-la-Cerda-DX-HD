namespace GbsPlayer
{
    public enum SoundState
    {
        Stopped,
        Playing,
        Paused
    }

    public interface IAudioOutput
    {
        SoundState State { get; }
        int GetPendingBufferCount();
        void Play();
        void Pause();
        void Resume();
        void Stop();
        void SetVolume(float volume);
        void SubmitBuffer(byte[] buffer, int offset, int count);
    }
}
