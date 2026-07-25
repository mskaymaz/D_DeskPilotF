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
}

} // namespace DeskPilot
