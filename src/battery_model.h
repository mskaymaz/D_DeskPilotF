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
    void visibleChanged();
    void appearanceChanged();
    void scaleChanged();

private:
    void updateState();

    IBatteryService *m_service = nullptr;
    BatteryState m_state = BatteryState::unavailable();
    bool m_visible = true;
    QString m_fontFamily;
    QColor m_fontColor = QColor("#6B7280");
    bool m_bold = false;
    qreal m_scale = 1.0;
    int m_lowBatteryThreshold = 20;
};

} // namespace DeskPilot
