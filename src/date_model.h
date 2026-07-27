#pragma once

#include <QColor>
#include <QDate>
#include <QObject>
#include <QString>

namespace DeskPilot {

class DateModel final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDate currentDate READ currentDate NOTIFY currentDateChanged)
    Q_PROPERTY(QString gregorianText READ gregorianText NOTIFY gregorianTextChanged)
    Q_PROPERTY(QString hijriText READ hijriText NOTIFY hijriTextChanged)
    Q_PROPERTY(QString dateFormat READ dateFormat WRITE setDateFormat NOTIFY dateFormatChanged)
    Q_PROPERTY(bool showWeekNumber READ showWeekNumber WRITE setShowWeekNumber
                   NOTIFY showWeekNumberChanged)
    Q_PROPERTY(QString weekNumberText READ weekNumberText NOTIFY weekNumberTextChanged)
    Q_PROPERTY(QString hijriWeekNumberText READ hijriWeekNumberText NOTIFY hijriWeekNumberTextChanged)
    Q_PROPERTY(bool gregorianFirst READ gregorianFirst WRITE setGregorianFirst
                   NOTIFY dateOrderChanged)
    Q_PROPERTY(QString fontFamily READ fontFamily WRITE setFontFamily NOTIFY fontFamilyChanged)
    Q_PROPERTY(bool useEmbeddedFont READ useEmbeddedFont WRITE setUseEmbeddedFont
                   NOTIFY useEmbeddedFontChanged)
    Q_PROPERTY(QColor fontColor READ fontColor WRITE setFontColor NOTIFY fontColorChanged)
    Q_PROPERTY(bool bold READ bold WRITE setBold NOTIFY boldChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(qreal scale READ scale WRITE setScale NOTIFY scaleChanged)

public:
    explicit DateModel(QObject *parent = nullptr);

    QDate currentDate() const;
    QString gregorianText() const;
    QString hijriText() const;
    QString dateFormat() const;
    void setDateFormat(const QString &value);
    bool showWeekNumber() const;
    void setShowWeekNumber(bool value);
    QString weekNumberText() const;
    QString hijriWeekNumberText() const;
    bool gregorianFirst() const;
    void setGregorianFirst(bool value);
    QString fontFamily() const;
    void setFontFamily(const QString &value);
    bool useEmbeddedFont() const;
    void setUseEmbeddedFont(bool value);
    QColor fontColor() const;
    void setFontColor(const QColor &value);
    bool bold() const;
    void setBold(bool value);
    bool visible() const;
    void setVisible(bool value);
    qreal scale() const;
    void setScale(qreal value);
    void setCurrentDate(const QDate &value);

signals:
    void currentDateChanged();
    void gregorianTextChanged();
    void hijriTextChanged();
    void dateFormatChanged();
    void showWeekNumberChanged();
    void weekNumberTextChanged();
    void hijriWeekNumberTextChanged();
    void dateOrderChanged();
    void fontFamilyChanged();
    void useEmbeddedFontChanged();
    void fontColorChanged();
    void boldChanged();
    void visibleChanged();
    void scaleChanged();

private:
    void updateDateTexts();

    QDate m_currentDate;
    QString m_gregorianText = QStringLiteral("--.--.----");
    QString m_hijriText = QStringLiteral("--.--.----");
    QString m_dateFormat = QStringLiteral("dd.MM.yyyy");
    QString m_weekNumberText = QStringLiteral("--");
    QString m_hijriWeekNumberText = QStringLiteral("--");
    bool m_showWeekNumber = false;
    bool m_gregorianFirst = true;
    QString m_fontFamily;
    bool m_useEmbeddedFont = true;
    QColor m_fontColor = QColor("#6B7280");
    bool m_bold = false;
    bool m_visible = true;
    qreal m_scale = 1.0;
};

} // namespace DeskPilot
