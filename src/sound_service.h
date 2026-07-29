#pragma once

#include <QObject>
#include <QString>

namespace DeskPilot {

class SoundService : public QObject
{
    Q_OBJECT

public:
    explicit SoundService(QObject *parent = nullptr);
    ~SoundService() override;

    Q_INVOKABLE void playAlarm();
    Q_INVOKABLE void stopAlarm();

private:
    bool m_isPlaying = false;
};

} // namespace DeskPilot
