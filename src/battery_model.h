#pragma once

#include <QColor>
#include <QObject>
#include <QString>

#include "battery_service.h"

namespace DeskPilot {

class BatteryModel final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available NOTIFY stateChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(int percentage READ percentage NOTIFY stateChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY stateChanged)
    Q_PROPERTY(bool pluggedIn READ pluggedIn NOTIFY stateChanged)
    Q_PROPERTY(bool charging READ charging NOTIFY stateChanged)
    Q_PROPERTY(int lowBatteryThreshold READ lowBatteryThreshold WRITE setLowBatteryThreshold
                   NOTIFY lowBatteryThresholdChanged)
    Q_PROPERTY(bool lowBattery READ lowBattery NOTIFY lowBatteryChanged)
    Q_PROPERTY(int fullChargeThreshold READ fullChargeThreshold WRITE setFullChargeThreshold
                   NOTIFY fullChargeThresholdChanged)
    Q_PROPERTY(bool fullCharge READ fullCharge NOTIFY fullChargeChanged)
    Q_PROPERTY(int alertIntervalMinutes READ alertIntervalMinutes WRITE setAlertIntervalMinutes
                   NOTIFY alertIntervalChanged)
    Q_PROPERTY(bool alertSoundEnabled READ alertSoundEnabled WRITE setAlertSoundEnabled
                   NOTIFY alertSoundEnabledChanged)
    Q_PROPERTY(bool silentMode READ silentMode WRITE setSilentMode NOTIFY silentModeChanged)
    Q_PROPERTY(bool audibleAlertsEnabled READ audibleAlertsEnabled NOTIFY alertSoundStateChanged)
    Q_PROPERTY(bool showIcon READ showIcon WRITE setShowIcon NOTIFY appearanceChanged)
    Q_PROPERTY(QString fontFamily READ fontFamily WRITE setFontFamily NOTIFY appearanceChanged)
    Q_PROPERTY(QColor fontColor READ fontColor WRITE setFontColor NOTIFY appearanceChanged)
    Q_PROPERTY(bool bold READ bold WRITE setBold NOTIFY appearanceChanged)
    Q_PROPERTY(qreal scale READ scale WRITE setScale NOTIFY scaleChanged)

public:
    explicit BatteryModel(IBatteryService *service, QObject *parent = nullptr);

    bool available() const;
    bool visible() const;
    void setVisible(bool value);
    int percentage() const;
    QString statusText() const;
    bool pluggedIn() const;
    bool charging() const;
    int lowBatteryThreshold() const;
    void setLowBatteryThreshold(int value);
    bool lowBattery() const;
    int fullChargeThreshold() const;
    void setFullChargeThreshold(int value);
    bool fullCharge() const;
    int alertIntervalMinutes() const;
    void setAlertIntervalMinutes(int value);
    bool alertSoundEnabled() const;
    void setAlertSoundEnabled(bool value);
    bool silentMode() const;
    void setSilentMode(bool value);
    bool audibleAlertsEnabled() const;
    bool showIcon() const;
    void setShowIcon(bool value);
    QString fontFamily() const;
    void setFontFamily(const QString &value);
    QColor fontColor() const;
    void setFontColor(const QColor &value);
    bool bold() const;
    void setBold(bool value);
    qreal scale() const;
    void setScale(qreal value);

    Q_INVOKABLE void refresh();

signals:
    void stateChanged();
    void lowBatteryThresholdChanged();
    void lowBatteryChanged();
    void fullChargeThresholdChanged();
    void fullChargeChanged();
    void alertIntervalChanged();
    void alertSoundEnabledChanged();
    void silentModeChanged();
    void alertSoundStateChanged();
    void visibleChanged();
    void appearanceChanged();
    void scaleChanged();

private:
    void updateState();

    IBatteryService *m_service = nullptr;
    BatteryState m_state = BatteryState::unavailable();
    bool m_visible = true;
    bool m_showIcon = true;
    QString m_fontFamily;
    QColor m_fontColor = QColor("#6B7280");
    bool m_bold = false;
    qreal m_scale = 1.0;
    int m_lowBatteryThreshold = 20;
    int m_fullChargeThreshold = 100;
    int m_alertIntervalMinutes = 60;
    bool m_alertSoundEnabled = true;
    bool m_silentMode = false;
};

} // namespace DeskPilot
