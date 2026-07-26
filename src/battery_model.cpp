#include "battery_model.h"

namespace DeskPilot {

BatteryModel::BatteryModel(IBatteryService *service, QObject *parent)
    : QObject(parent)
    , m_service(service)
{
    updateState();
}

bool BatteryModel::available() const
{
    return m_state.present;
}

bool BatteryModel::visible() const
{
    return m_visible;
}

void BatteryModel::setVisible(bool value)
{
    if (m_visible == value) {
        return;
    }

    m_visible = value;
    emit visibleChanged();
}

int BatteryModel::percentage() const
{
    return m_state.percentage;
}

QString BatteryModel::statusText() const
{
    switch (m_state.status) {
    case BatteryStatus::Charging:
        return QStringLiteral("Şarj oluyor");
    case BatteryStatus::Discharging:
        return QStringLiteral("Pil kullanılıyor");
    case BatteryStatus::Full:
        return QStringLiteral("Tam dolu");
    case BatteryStatus::Unknown:
        return QStringLiteral("Bilinmiyor");
    case BatteryStatus::NotPresent:
        return QStringLiteral("Pil yok");
    }

    return QStringLiteral("Bilinmiyor");
}

bool BatteryModel::pluggedIn() const
{
    return m_state.pluggedIn;
}

bool BatteryModel::charging() const
{
    return m_state.status == BatteryStatus::Charging;
}

int BatteryModel::lowBatteryThreshold() const
{
    return m_lowBatteryThreshold;
}

void BatteryModel::setLowBatteryThreshold(int value)
{
    const int normalizedValue = qBound(0, value, 100);
    if (m_lowBatteryThreshold == normalizedValue) {
        return;
    }

    m_lowBatteryThreshold = normalizedValue;
    emit lowBatteryThresholdChanged();
    emit lowBatteryChanged();
}

bool BatteryModel::lowBattery() const
{
    return m_state.present
        && m_state.status == BatteryStatus::Discharging
        && m_state.percentage >= 0
        && m_state.percentage <= m_lowBatteryThreshold;
}

int BatteryModel::fullChargeThreshold() const
{
    return m_fullChargeThreshold;
}

void BatteryModel::setFullChargeThreshold(int value)
{
    const int normalizedValue = qBound(0, value, 100);
    if (m_fullChargeThreshold == normalizedValue) {
        return;
    }

    m_fullChargeThreshold = normalizedValue;
    emit fullChargeThresholdChanged();
    emit fullChargeChanged();
}

bool BatteryModel::fullCharge() const
{
    const bool chargingState = m_state.status == BatteryStatus::Charging
        || m_state.status == BatteryStatus::Full;
    return m_state.present
        && m_state.pluggedIn
        && chargingState
        && m_state.percentage >= 0
        && m_state.percentage >= m_fullChargeThreshold;
}

int BatteryModel::alertIntervalMinutes() const
{
    return m_alertIntervalMinutes;
}

void BatteryModel::setAlertIntervalMinutes(int value)
{
    const int normalizedValue = qBound(1, value, 1440);
    if (m_alertIntervalMinutes == normalizedValue) {
        return;
    }

    m_alertIntervalMinutes = normalizedValue;
    emit alertIntervalChanged();
}

bool BatteryModel::alertSoundEnabled() const
{
    return m_alertSoundEnabled;
}

void BatteryModel::setAlertSoundEnabled(bool value)
{
    if (m_alertSoundEnabled == value) {
        return;
    }

    m_alertSoundEnabled = value;
    emit alertSoundEnabledChanged();
    emit alertSoundStateChanged();
}

bool BatteryModel::silentMode() const
{
    return m_silentMode;
}

void BatteryModel::setSilentMode(bool value)
{
    if (m_silentMode == value) {
        return;
    }

    m_silentMode = value;
    emit silentModeChanged();
    emit alertSoundStateChanged();
}

bool BatteryModel::audibleAlertsEnabled() const
{
    return m_alertSoundEnabled && !m_silentMode;
}

bool BatteryModel::showIcon() const
{
    return m_showIcon;
}

void BatteryModel::setShowIcon(bool value)
{
    if (m_showIcon == value) {
        return;
    }

    m_showIcon = value;
    emit appearanceChanged();
}

QString BatteryModel::fontFamily() const
{
    return m_fontFamily;
}

void BatteryModel::setFontFamily(const QString &value)
{
    if (m_fontFamily == value) {
        return;
    }

    m_fontFamily = value;
    emit appearanceChanged();
}

QColor BatteryModel::fontColor() const
{
    return m_fontColor;
}

void BatteryModel::setFontColor(const QColor &value)
{
    if (m_fontColor == value) {
        return;
    }

    m_fontColor = value;
    emit appearanceChanged();
}

bool BatteryModel::bold() const
{
    return m_bold;
}

void BatteryModel::setBold(bool value)
{
    if (m_bold == value) {
        return;
    }

    m_bold = value;
    emit appearanceChanged();
}

qreal BatteryModel::scale() const
{
    return m_scale;
}

void BatteryModel::setScale(qreal value)
{
    if (qFuzzyCompare(m_scale, value)) {
        return;
    }

    m_scale = qMax<qreal>(0.1, value);
    emit scaleChanged();
}

void BatteryModel::refresh()
{
    if (m_service == nullptr) {
        return;
    }

    m_service->refresh();
    updateState();
}

void BatteryModel::updateState()
{
    const BatteryState nextState = m_service != nullptr
        ? m_service->currentState()
        : BatteryState::unavailable();

    if (m_state.present == nextState.present
        && m_state.percentage == nextState.percentage
        && m_state.status == nextState.status
        && m_state.pluggedIn == nextState.pluggedIn) {
        return;
    }

    m_state = nextState;
    emit stateChanged();
    emit lowBatteryChanged();
    emit fullChargeChanged();
}

} // namespace DeskPilot
