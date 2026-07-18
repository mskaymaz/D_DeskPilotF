#pragma once

#include <QColor>
#include <QDateTime>
#include <QObject>
#include <QString>

namespace DeskPilot {

class ClockModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(bool showSeconds READ showSeconds WRITE setShowSeconds NOTIFY showSecondsChanged)
    Q_PROPERTY(bool use24HourFormat READ use24HourFormat WRITE setUse24HourFormat NOTIFY use24HourFormatChanged)
    Q_PROPERTY(QString fontFamily READ fontFamily WRITE setFontFamily NOTIFY fontFamilyChanged)
    Q_PROPERTY(QColor fontColor READ fontColor WRITE setFontColor NOTIFY fontColorChanged)
    Q_PROPERTY(bool bold READ bold WRITE setBold NOTIFY boldChanged)
    Q_PROPERTY(bool useEmbeddedFont READ useEmbeddedFont WRITE setUseEmbeddedFont NOTIFY useEmbeddedFontChanged)
    Q_PROPERTY(qreal scale READ scale WRITE setScale NOTIFY scaleChanged)
    Q_PROPERTY(qreal secondsScale READ secondsScale WRITE setSecondsScale NOTIFY secondsScaleChanged)
    Q_PROPERTY(QString timeText READ timeText NOTIFY timeTextChanged)
    Q_PROPERTY(QString primaryTimeText READ primaryTimeText NOTIFY primaryTimeTextChanged)
    Q_PROPERTY(QString secondsText READ secondsText NOTIFY secondsTextChanged)

public:
    explicit ClockModel(QObject *parent = nullptr);

    bool visible() const;
    void setVisible(bool value);
    bool showSeconds() const;
    void setShowSeconds(bool value);
    bool use24HourFormat() const;
    void setUse24HourFormat(bool value);
    QString fontFamily() const;
    void setFontFamily(const QString &value);
    QColor fontColor() const;
    void setFontColor(const QColor &value);
    bool bold() const;
    void setBold(bool value);
    bool useEmbeddedFont() const;
    void setUseEmbeddedFont(bool value);
    qreal scale() const;
    void setScale(qreal value);
    qreal secondsScale() const;
    void setSecondsScale(qreal value);
    QString timeText() const;
    QString primaryTimeText() const;
    QString secondsText() const;
    void setCurrentDateTime(const QDateTime &value);

signals:
    void visibleChanged();
    void showSecondsChanged();
    void use24HourFormatChanged();
    void fontFamilyChanged();
    void fontColorChanged();
    void boldChanged();
    void useEmbeddedFontChanged();
    void scaleChanged();
    void secondsScaleChanged();
    void timeTextChanged();
    void primaryTimeTextChanged();
    void secondsTextChanged();

private:
    void updateTimeText();

    bool m_visible = true;
    bool m_showSeconds = false;
    bool m_use24HourFormat = true;
    QString m_fontFamily;
    QColor m_fontColor = QColor("#111827");
    bool m_bold = false;
    bool m_useEmbeddedFont = true;
    qreal m_scale = 1.0;
    qreal m_secondsScale = 1.0;
    QDateTime m_currentDateTime;
    QString m_timeText = "--:--";
    QString m_primaryTimeText = "--:--";
    QString m_secondsText;
};

} // namespace DeskPilot
