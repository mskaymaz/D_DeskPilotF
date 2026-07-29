#include "sound_service.h"

#include <QCoreApplication>
#include <QString>
#include <QDir>
#include <QFile>
#include <QDebug>

#if defined(Q_OS_WIN)
#include <windows.h>
#include <mmsystem.h>
#endif

namespace DeskPilot {

SoundService::SoundService(QObject *parent)
    : QObject(parent)
{
}

SoundService::~SoundService()
{
    stopAlarm();
}

void SoundService::playAlarm()
{
    if (m_isPlaying) {
        return;
    }

#if defined(Q_OS_WIN)
    QString soundPath = QCoreApplication::applicationDirPath() + "/assets/audio/alarm.wav";
    // Convert QString to const wchar_t*
    const wchar_t* path = reinterpret_cast<const wchar_t*>(soundPath.utf16());
    
    // Check if file exists, else use system beep
    if (QFile::exists(soundPath)) {
        PlaySoundW(path, NULL, SND_FILENAME | SND_ASYNC | SND_LOOP);
        m_isPlaying = true;
    } else {
        qWarning() << "Alarm sound file not found:" << soundPath << "- playing default system sound.";
        PlaySoundW(reinterpret_cast<const wchar_t*>(QString("SystemAsterisk").utf16()), NULL, SND_ALIAS | SND_ASYNC | SND_LOOP);
        m_isPlaying = true;
    }
#else
    qWarning() << "Sound playback is only implemented for Windows.";
#endif
}

void SoundService::stopAlarm()
{
    if (!m_isPlaying) {
        return;
    }

#if defined(Q_OS_WIN)
    PlaySoundW(NULL, 0, 0);
    m_isPlaying = false;
#endif
}

} // namespace DeskPilot
