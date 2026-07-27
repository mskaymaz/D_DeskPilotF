#include "date_model.h"

#include <QCalendar>
#include <QLocale>

namespace DeskPilot {

DateModel::DateModel(QObject *parent)
    : QObject(parent)
{
}

QDate DateModel::currentDate() const
{
    return m_currentDate;
}

QString DateModel::gregorianText() const
{
    return m_gregorianText;
}

QString DateModel::hijriText() const
{
    return m_hijriText;
}

QString DateModel::dateFormat() const
{
    return m_dateFormat;
}

void DateModel::setDateFormat(const QString &value)
{
    if (value != QStringLiteral("dd.MM.yyyy")
        && value != QStringLiteral("dd/MM/yyyy")
        && value != QStringLiteral("yyyy-MM-dd")) {
        return;
    }
    if (m_dateFormat == value) {
        return;
    }

    m_dateFormat = value;
    emit dateFormatChanged();
    updateDateTexts();
}

bool DateModel::showWeekNumber() const
{
    return m_showWeekNumber;
}

void DateModel::setShowWeekNumber(bool value)
{
    if (m_showWeekNumber == value) {
        return;
    }

    m_showWeekNumber = value;
    emit showWeekNumberChanged();
}

QString DateModel::weekNumberText() const
{
    return m_weekNumberText;
}

QString DateModel::hijriWeekNumberText() const
{
    return m_hijriWeekNumberText;
}

bool DateModel::gregorianFirst() const
{
    return m_gregorianFirst;
}

void DateModel::setGregorianFirst(bool value)
{
    if (m_gregorianFirst == value) {
        return;
    }

    m_gregorianFirst = value;
    emit dateOrderChanged();
}

QString DateModel::fontFamily() const
{
    return m_fontFamily;
}

void DateModel::setFontFamily(const QString &value)
{
    if (m_fontFamily == value) {
        return;
    }

    m_fontFamily = value;
    emit fontFamilyChanged();
}

bool DateModel::useEmbeddedFont() const
{
    return m_useEmbeddedFont;
}

void DateModel::setUseEmbeddedFont(bool value)
{
    if (m_useEmbeddedFont == value) {
        return;
    }

    m_useEmbeddedFont = value;
    emit useEmbeddedFontChanged();
}

QColor DateModel::fontColor() const
{
    return m_fontColor;
}

void DateModel::setFontColor(const QColor &value)
{
    if (m_fontColor == value) {
        return;
    }

    m_fontColor = value;
    emit fontColorChanged();
}

bool DateModel::bold() const
{
    return m_bold;
}

void DateModel::setBold(bool value)
{
    if (m_bold == value) {
        return;
    }

    m_bold = value;
    emit boldChanged();
}

bool DateModel::visible() const
{
    return m_visible;
}

void DateModel::setVisible(bool value)
{
    if (m_visible == value) {
        return;
    }

    m_visible = value;
    emit visibleChanged();
}

qreal DateModel::scale() const
{
    return m_scale;
}

void DateModel::setScale(qreal value)
{
    if (qFuzzyCompare(m_scale, value)) {
        return;
    }

    m_scale = qMax<qreal>(0.1, value);
    emit scaleChanged();
}

void DateModel::setCurrentDate(const QDate &value)
{
    if (m_currentDate == value) {
        return;
    }

    m_currentDate = value;
    emit currentDateChanged();
    updateDateTexts();
}

void DateModel::updateDateTexts()
{
    const QLocale turkishLocale(QLocale::Turkish, QLocale::Turkey);
    const QString nextGregorianText = m_currentDate.isValid()
        ? turkishLocale.toString(m_currentDate, m_dateFormat)
        : QStringLiteral("--.--.----");
    if (m_gregorianText != nextGregorianText) {
        m_gregorianText = nextGregorianText;
        emit gregorianTextChanged();
    }

    const QCalendar islamicCivilCalendar(QCalendar::System::IslamicCivil);
    const QString nextHijriText = m_currentDate.isValid()
        ? turkishLocale.toString(m_currentDate, m_dateFormat, islamicCivilCalendar)
        : QStringLiteral("--.--.----");
    if (m_hijriText != nextHijriText) {
        m_hijriText = nextHijriText;
        emit hijriTextChanged();
    }

    // Hijri week number (approximate)
    int hijriWeekNumber = 0;
    if (m_currentDate.isValid()) {
        auto ymd = islamicCivilCalendar.partsFromDate(m_currentDate);
        int dayOfYear = ymd.day;
        for (int m = 1; m < ymd.month; ++m) {
            dayOfYear += islamicCivilCalendar.daysInMonth(m, ymd.year);
        }
        hijriWeekNumber = (dayOfYear + 6) / 7; // simple week calc
    }
    const QString nextHijriWeekNumberText = m_currentDate.isValid()
        ? QString::number(hijriWeekNumber)
        : QStringLiteral("--");
    if (m_hijriWeekNumberText != nextHijriWeekNumberText) {
        m_hijriWeekNumberText = nextHijriWeekNumberText;
        emit hijriWeekNumberTextChanged();
    }

    const QString nextWeekNumberText = m_currentDate.isValid()
        ? QString::number(m_currentDate.weekNumber())
        : QStringLiteral("--");
    if (m_weekNumberText != nextWeekNumberText) {
        m_weekNumberText = nextWeekNumberText;
        emit weekNumberTextChanged();
    }
}

} // namespace DeskPilot
