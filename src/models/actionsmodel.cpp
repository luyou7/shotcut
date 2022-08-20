/*
 * Copyright (c) 2022 Meltytech, LLC
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "actionsmodel.h"

#include "actions.h"
#include <Logger.h>

#include <QAction>
#include <QKeySequence>

ActionsModel::ActionsModel(QObject *parent)
    : QAbstractItemModel(parent)
    , m_keys(Actions.keys())
{
}

QAction *ActionsModel::action(const QModelIndex &index) const
{
    if (index.row() < m_keys.size()) {
        return Actions[m_keys[index.row()]];
    }
    return nullptr;
}

int ActionsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_keys.size();
}

int ActionsModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return COLUMN_COUNT;
}

QVariant ActionsModel::data(const QModelIndex &index, int role) const
{
    QVariant result;

    switch (role) {
    case Qt::StatusTipRole:
    case Qt::DecorationRole:
    case Qt::FontRole:
    case Qt::TextAlignmentRole:
    case Qt::CheckStateRole:
    case Qt::SizeHintRole:
    case Qt::BackgroundRole:
    case Qt::ForegroundRole:
        return result;
    }

    if (!index.isValid() || index.column() < 0 || index.column() >= COLUMN_COUNT || index.row() < 0
            || index.row() >= m_keys.size()) {
        LOG_ERROR() << "Invalid Index: " << index.row() << index.column() << role;
        return result;
    }

    QString key = m_keys[index.row()];
    QAction *action = Actions[key];
    switch (role) {
    case Qt::DisplayRole:
        switch (index.column()) {
        case COLUMN_ACTION:
            result = action->property(Actions.groupProperty).toString() + " > " + action->iconText();
            break;
        case COLUMN_SEQUENCE1: {
            QList<QKeySequence> sequences = action->shortcuts();
            if (sequences.size() > 0)
                result = sequences[0].toString();
        }
        break;
        case COLUMN_SEQUENCE2: {
            result = action->property(Actions.hardKeyProperty);
            if (result.toString().isEmpty()) {
                QList<QKeySequence> sequences = action->shortcuts();
                if (sequences.size() > 1)
                    result = sequences[1].toString();
            }
        }
        break;
        default:
            LOG_ERROR() << "Invalid Column" << index.column() << role;
            break;
        }
        break;
    case Qt::ToolTipRole:
        result = action->toolTip();
        break;
    default:
        LOG_ERROR() << "Invalid Role" << index.row() << index.column() << roleNames()[role] << role;
        break;
    }
    return result;
}

QVariant ActionsModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (role == Qt::DisplayRole && orientation == Qt::Horizontal) {
        switch (section) {
        case COLUMN_ACTION:
            return tr("Action");
        case COLUMN_SEQUENCE1:
            return tr("Shortcut 1");
        case COLUMN_SEQUENCE2:
            return tr("Shortcut 2");
        default:
            LOG_ERROR() << "Invalid section" << section << roleNames()[role] << role;
            break;
        }
    }
    return QVariant();
}

QModelIndex ActionsModel::index(int row, int column, const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    if (column < 0 || column >= COLUMN_COUNT || row < 0 || row >= m_keys.size())
        return QModelIndex();
    return createIndex(row, column, (int)0);
}

QModelIndex ActionsModel::parent(const QModelIndex &index) const
{
    Q_UNUSED(index)
    return QModelIndex();
}

Qt::ItemFlags ActionsModel::flags(const QModelIndex &index) const
{
    Qt::ItemFlags flags = Qt::ItemIsEnabled | Qt::ItemIsSelectable;
    if (index.column() == COLUMN_SEQUENCE1 || index.column() == COLUMN_SEQUENCE2) {
//        flags |= Qt::ItemIsEditable;
    }
    return flags;
}
