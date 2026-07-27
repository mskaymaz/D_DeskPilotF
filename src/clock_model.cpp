#include "clock_model.h"

namespace DeskPilot {

ClockModel::ClockModel(QObject *parent)
    : QObject(parent)
{
}

bool ClockModel::visible() const { return m_visible; }
void ClockModel::setVisible(bool value)
{
    if (m_visible == value) return;
    m_visible = value;
    emit visibleChanged();
}

bool ClockModel::showSeconds() const { return m_showSeconds; }
void ClockModel::setShowSeconds(bool value)
{
    if (m_showSeconds == value) return;
    m_showSeconds = value;
    emit showSecondsChanged();
    updateTimeText();
}

bool ClockModel::use24HourFormat() const { return m_use24HourFormat; }
void ClockModel::setUse24HourFormat(bool value)
{
    if (m_use24HourFormat == value) return;
    m_use24HourFormat = value;
    emit use24HourFormatChanged();
    updateTimeText();
}

QString ClockModel::fontFamily() const { return m_fontFamily; }
void ClockModel::setFontFamily(const QString &value)
{
    if (m_fontFamily == value) return;
    m_fontFamily = value;
    emit fontFamilyChanged();
}

QColor ClockModel::fontColor() const { return m_fontColor; }
void ClockModel::setFontColor(const QColor &value)
{
    if (m_fontColor == value) return;
    m_fontColor = value;
    emit fontColorChanged();
}

bool ClockModel::bold() const { return m_bold; }
void ClockModel::setBold(bool value)
{
    if (m_bold == value) return;
    m_bold = value;
    emit boldChanged();
}

bool ClockModel::useEmbeddedFont() const { return m_useEmbeddedFont; }
void ClockModel::setUseEmbeddedFont(bool value)
{
    if (m_useEmbeddedFont == value) return;
    m_useEmbeddedFont = value;
    emit useEmbeddedFontChanged();
}

qreal ClockModel::scale() const { return m_scale; }
void ClockModel::setScale(qreal value)
{
    if (qFuzzyCompare(m_scale, value)) return;
    m_scale = qMax<qreal>(0.1, value);
    emit scaleChanged();
}

qreal ClockModel::secondsScale() const { return m_secondsScale; }
void ClockModel::setSecondsScale(qreal value)
{
    if (qFuzzyCompare(m_secondsScale, value)) return;
    m_secondsScale = qMax<qreal>(0.1, value);
    emit secondsScaleChanged();
}

QString ClockModel::timeText() const
{
    return m_timeText;
}

QString ClockModel::primaryTimeText() const
{
    return m_primaryTimeText;
}

QString ClockModel::secondsText() const
{
    return m_secondsText;
}

void ClockModel::setCurrentDateTime(const QDateTime &value)
{
    if (m_currentDateTime == value) {
        return;
    }
    m_currentDateTime = value;
    updateTimeText();
}

void ClockModel::updateTimeText()
{
    if (!m_currentDateTime.isValid()) {
        return;
    }

    const QString primaryFormat = m_use24HourFormat ? QStringLiteral("HH:mm")
                                                     : QStringLiteral("hh:mm ap");
    const QString nextPrimaryText = m_currentDateTime.toString(primaryFormat);
    const QString nextSecondsText = m_showSeconds
        ? m_currentDateTime.toString(QStringLiteral("ss"))
        : QString();
    const QString nextText = m_showSeconds
        ? m_currentDateTime.toString(
            m_use24HourFormat ? QStringLiteral("HH:mm:ss")
                              : QStringLiteral("hh:mm:ss ap"))
        : nextPrimaryText;

    if (m_timeText != nextText) {
        m_timeText = nextText;
        emit timeTextChanged();
    }
    if (m_primaryTimeText != nextPrimaryText) {
        m_primaryTimeText = nextPrimaryText;
        emit primaryTimeTextChanged();
    }
    if (m_secondsText != nextSecondsText) {
        m_secondsText = nextSecondsText;
        emit secondsTextChanged();
    }
}

} // namespace DeskPilot
