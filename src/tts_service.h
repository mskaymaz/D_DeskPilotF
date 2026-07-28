#pragma once

#include <QObject>
#include <QString>

namespace DeskPilot {

class TtsService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool useFemaleVoice READ useFemaleVoice WRITE setUseFemaleVoice NOTIFY voiceChanged)

public:
    explicit TtsService(QObject *parent = nullptr);
    ~TtsService() override;

    bool useFemaleVoice() const { return m_useFemaleVoice; }
    void setUseFemaleVoice(bool female);

    Q_INVOKABLE void speak(const QString &text);
    Q_INVOKABLE void stop();

signals:
    void voiceChanged();

private:
    void initializeVoice();
    
    bool m_useFemaleVoice = false;
    void *m_voiceContext = nullptr; // Opaque pointer to ISpVoice
};

} // namespace DeskPilot
