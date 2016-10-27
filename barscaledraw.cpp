#include "barscaledraw.h"

#include <qwt_text.h>

BarScaleDraw::BarScaleDraw() : QwtScaleDraw()
{
}

BarScaleDraw::BarScaleDraw(Qt::Orientation t_orientation, const QStringList &t_labels) : m_labels(t_labels)
{
  setTickLength(QwtScaleDiv::MinorTick, 0);
  setTickLength(QwtScaleDiv::MediumTick, 0);
  setTickLength(QwtScaleDiv::MajorTick, 2);

  enableComponent(QwtScaleDraw::Backbone, false);

  if (t_orientation == Qt::Vertical)
  {
    setLabelRotation(-60.0);
  }
  else
  {
    setLabelRotation(-20.0);
  }

  setLabelAlignment(Qt::AlignLeft | Qt::AlignVCenter);
}

void BarScaleDraw::setColor(QColor t_arg)
{
  m_textColor=t_arg;
}

QwtText BarScaleDraw::label(double t_value) const
{
  QwtText lbl;
  if(m_labels.count()>t_value)
  {
    const int index = qRound(t_value);
    if (index >= 0 && index < m_labels.size())
    {
      lbl = m_labels.at(index);
    }
  }
  else
  {
    lbl = QwtText (QString::number (t_value));
  }
  lbl.setColor(m_textColor);
  return lbl;
}
