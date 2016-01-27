/*
	This file is part of cpp-ethereum.
	cpp-ethereum is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	cpp-ethereum is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	You should have received a copy of the GNU General Public License
	along with cpp-ethereum.  If not, see <http://www.gnu.org/licenses/>.
*/
/** @file DisableInput.qml
 * @author Yann yann@ethdev.com
 * @date 2016
 * Ethereum IDE client.
 */

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.1
import org.ethereum.qml.InverseMouseArea 1.0

Item
{
	property var actions: []
	id: root
	function init()
	{
		actionsModel.clear()
		actionLabels.height = 0
		for (var k in actions)
			actionsModel.append({ index: k, label: actions[k].label })
	}

	InverseMouseArea
	{
		id: inverseMouse
		anchors.fill: parent
		active: false
		onClickedOutside: {
			for (var k = 0; k < actionsModel.count; k++)
			{
				if (actionsRepeater.itemAt(k).containsMouse())
					return
			}
			actionLabels.visible = false
			inverseMouse.active = false
		}
	}

	ScenarioButton
	{
		id: labelButton
		roundLeft: true
		roundRight: true
		width: 30
		height: 30
		sourceImg: "qrc:/qml/img/plus.png"
		text: qsTr("Add Transaction/Block")
		onClicked:
		{
			btnClicked()
		}

		function btnClicked()
		{
			if (actionLabels.visible)
				actionLabels.visible = false
			else
			{
				parent.init()
				var top = labelButton;
				while (top.parent)
					top = top.parent
				actionLabels.parent = top
				var globalCoord = labelButton.mapToItem(null, 0, 0);
				actionLabels.x = globalCoord.x + labelButton.width
				actionLabels.y = globalCoord.y
				actionLabels.z = 50
				actionLabels.visible = true
				inverseMouse.active = true
			}
		}
	}

	Rectangle
	{
		id: actionLabels
		visible: false
		width: (5 * appSettings.systemPointSize) + minWidth
		property int minHeight: 35
		property int minWidth: 150
		Connections
		{
			target: appSettings
			onSystemPointSizeChanged:
			{
				updateSize()
			}

			Component.onCompleted:
			{
				updateSize()
			}

			function updateSize()
			{
				if (actionLabels.visible)
				{
					actionLabels.visible = falses
					labelButton.btnClicked()
				}
			}
		}

		ColumnLayout
		{
			id: actionsCol
			spacing: 5
			ListModel
			{
				id: actionsModel
			}

			Repeater
			{
				id: actionsRepeater
				model: actionsModel
				Rectangle
				{
					function containsMouse()
					{
						return mouseAreaAction.containsMouse
					}
					color: mouseAreaAction.containsMouse ? "#cccccc" : "transparent"
					width: actionLabels.width
					height: labelAction.height + 10

					Component.onCompleted:
					{
						actionLabels.height += height + actionsCol.spacing
					}

					DefaultLabel
					{
						text: actions[index].label
						elide: Text.ElideRight
						id: labelAction
						anchors.left: parent.left
						anchors.leftMargin: 10
						anchors.verticalCenter: parent.verticalCenter
						MouseArea
						{
							id: mouseAreaAction
							anchors.fill: parent
							hoverEnabled: true
							onClicked:
							{
								actions[index].action()
								actionLabels.visible = false
							}
						}
					}
				}
			}
		}
	}
}
