

import QtQuick 2.1
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import Shotcut.Controls 1.0


Item {
    width: 350
    height: 180
    property bool blockUpdate: true

    property double yawStart : 0.0; property double yawMiddle : 0.0; property double yawEnd : 0.0;
    property double pitchStart : 0.0; property double pitchMiddle : 0.0; property double pitchEnd : 0.0;
    property double rollStart : 0.0; property double rollMiddle : 0.0; property double rollEnd : 0.0;
    property int interpolationValue : 0;
    property bool gridValue: false

    Connections { target: filter; onChanged: setControls(); onInChanged: { updateProperty_yaw (null); } onOutChanged: { updateProperty_yaw (null); } onAnimateInChanged: { updateProperty_yaw (null); } onAnimateOutChanged: { updateProperty_yaw (null); } }
    Connections { target: filter; onChanged: setControls(); onInChanged: { updateProperty_pitch (null); } onOutChanged: { updateProperty_pitch (null); } onAnimateInChanged: { updateProperty_pitch (null); } onAnimateOutChanged: { updateProperty_pitch (null); } }
    Connections { target: filter; onChanged: setControls(); onInChanged: { updateProperty_roll (null); } onOutChanged: { updateProperty_roll (null); } onAnimateInChanged: { updateProperty_roll (null); } onAnimateOutChanged: { updateProperty_roll (null); } }
    Connections { target: filter; onChanged: setControls(); onInChanged: { updateProperty_interpolation (); } onOutChanged: { updateProperty_interpolation (); } onAnimateInChanged: { updateProperty_interpolation (); } onAnimateOutChanged: { updateProperty_interpolation (); } }

    Component.onCompleted: {
        if (filter.isNew) { filter.set("yaw", 0); } else { yawMiddle = filter.getDouble("yaw", filter.animateIn); if (filter.animateIn > 0) { yawStart = filter.getDouble("yaw", 0); } if (filter.animateOut > 0) { yawEnd = filter.getDouble("yaw", filter.duration - 1); } }
        if (filter.isNew) { filter.set("pitch", 0); } else { pitchMiddle = filter.getDouble("pitch", filter.animateIn); if (filter.animateIn > 0) { pitchStart = filter.getDouble("pitch", 0); } if (filter.animateOut > 0) { pitchEnd = filter.getDouble("pitch", filter.duration - 1); } }
        if (filter.isNew) { filter.set("roll", 0); } else { rollMiddle = filter.getDouble("roll", filter.animateIn); if (filter.animateIn > 0) { rollStart = filter.getDouble("roll", 0); } if (filter.animateOut > 0) { rollEnd = filter.getDouble("roll", filter.duration - 1); } }
        if (filter.isNew) { filter.set("interpolation", 1); } else { interpolationValue = filter.get("interpolation"); }
        if (filter.isNew) { filter.set("grid", false); } else { gridValue = filter.get("grid") == '1'; }

        if (filter.isNew) {
            filter.savePreset(preset.parameters)
        }
        setControls()
    }

    function setControls() {
        var position = getPosition()
        blockUpdate = true
        yawSlider.value = filter.getDouble("yaw", position)
        pitchSlider.value = filter.getDouble("pitch", position)
        rollSlider.value = filter.getDouble("roll", position)
        interpolationComboBox.currentIndex = filter.get("interpolation")
        gridCheckBox.checked = filter.get("grid") == '1';
        blockUpdate = false
    }

    function updateProperty_yaw (position) { if (blockUpdate) return; var value = yawSlider.value; if (position !== null) { if (position <= 0 && filter.animateIn > 0) { yawStart = value; } else if (position >= filter.duration - 1 && filter.animateOut > 0) { yawEnd = value; } else { yawMiddle = value; } } if (filter.animateIn > 0 || filter.animateOut > 0) { filter.resetProperty("yaw"); yawKeyframesButton.checked = false; if (filter.animateIn > 0) { filter.set("yaw", yawStart, 0); filter.set("yaw", yawMiddle, filter.animateIn - 1); } if (filter.animateOut > 0) { filter.set("yaw", yawMiddle, filter.duration - filter.animateOut); filter.set("yaw", yawEnd, filter.duration - 1); } } else if (!yawKeyframesButton.checked) { filter.resetProperty("yaw"); filter.set("yaw", yawMiddle); } else if (position !== null) { filter.set("yaw", value, position); } }
    function updateProperty_pitch (position) { if (blockUpdate) return; var value = pitchSlider.value; if (position !== null) { if (position <= 0 && filter.animateIn > 0) { pitchStart = value; } else if (position >= filter.duration - 1 && filter.animateOut > 0) { pitchEnd = value; } else { pitchMiddle = value; } } if (filter.animateIn > 0 || filter.animateOut > 0) { filter.resetProperty("pitch"); pitchKeyframesButton.checked = false; if (filter.animateIn > 0) { filter.set("pitch", pitchStart, 0); filter.set("pitch", pitchMiddle, filter.animateIn - 1); } if (filter.animateOut > 0) { filter.set("pitch", pitchMiddle, filter.duration - filter.animateOut); filter.set("pitch", pitchEnd, filter.duration - 1); } } else if (!pitchKeyframesButton.checked) { filter.resetProperty("pitch"); filter.set("pitch", pitchMiddle); } else if (position !== null) { filter.set("pitch", value, position); } }
    function updateProperty_roll (position) { if (blockUpdate) return; var value = rollSlider.value; if (position !== null) { if (position <= 0 && filter.animateIn > 0) { rollStart = value; } else if (position >= filter.duration - 1 && filter.animateOut > 0) { rollEnd = value; } else { rollMiddle = value; } } if (filter.animateIn > 0 || filter.animateOut > 0) { filter.resetProperty("roll"); rollKeyframesButton.checked = false; if (filter.animateIn > 0) { filter.set("roll", rollStart, 0); filter.set("roll", rollMiddle, filter.animateIn - 1); } if (filter.animateOut > 0) { filter.set("roll", rollMiddle, filter.duration - filter.animateOut); filter.set("roll", rollEnd, filter.duration - 1); } } else if (!rollKeyframesButton.checked) { filter.resetProperty("roll"); filter.set("roll", rollMiddle); } else if (position !== null) { filter.set("roll", value, position); } }
    function updateProperty_interpolation () { if (blockUpdate) return; var value = interpolationComboBox.currentIndex; filter.set("interpolation", value); }
    function updateProperty_grid () { if (blockUpdate) return; var value = gridCheckBox.checked; filter.set("grid", value); }

    function getPosition() {
        return Math.max(producer.position - (filter.in - producer.in), 0)
    }

    GridLayout {
        columns: 4
        anchors.fill: parent
        anchors.margins: 8

        Label {
            text: qsTr('Preset')
            Layout.alignment: Qt.AlignRight
        }
        Preset {
            id: preset
            parameters: ["yaw", "pitch", "roll", "interpolation"]
            Layout.columnSpan: 3
            onBeforePresetLoaded: {
                filter.resetProperty('yaw')
                filter.resetProperty('pitch')
                filter.resetProperty('roll')
                filter.resetProperty('interpolation')
            }
            onPresetSelected: {
                yawMiddle = filter.getDouble("yaw", filter.animateIn); if (filter.animateIn > 0) { yawStart = filter.getDouble("yaw", 0); } if (filter.animateOut > 0) { yawEnd = filter.getDouble("yaw", filter.duration - 1); }
                pitchMiddle = filter.getDouble("pitch", filter.animateIn); if (filter.animateIn > 0) { pitchStart = filter.getDouble("pitch", 0); } if (filter.animateOut > 0) { pitchEnd = filter.getDouble("pitch", filter.duration - 1); }
                rollMiddle = filter.getDouble("roll", filter.animateIn); if (filter.animateIn > 0) { rollStart = filter.getDouble("roll", 0); } if (filter.animateOut > 0) { rollEnd = filter.getDouble("roll", filter.duration - 1); }
                interpolationValue = filter.get("interpolation");
                setControls(null);
            }
        }

        Label {
            text: qsTr('Interpolation')
            Layout.alignment: Qt.AlignRight
        }
        ComboBox {
            currentIndex: 0
            model: ["Nearest-neighbor", "Bilinear"]
            id: interpolationComboBox
            Layout.columnSpan: 2
            onCurrentIndexChanged: updateProperty_interpolation()
        }
        UndoButton {
            id: interpolationUndo
            onClicked: interpolationComboBox.currentIndex = 0
        }

        Label {
            text: qsTr('Yaw')
            Layout.alignment: Qt.AlignRight
        }
        SliderSpinner {
            id: yawSlider
            minimumValue: -360
            maximumValue: 360
            spinnerWidth: 120; suffix: ' deg'; decimals: 3; stepSize: 1;
            onValueChanged: updateProperty_yaw(getPosition())
        }
        KeyframesButton { id: yawKeyframesButton; checked: filter.animateIn <= 0 && filter.animateOut <= 0 && filter.keyframeCount("yaw") > 0; onToggled: { var value = yawSlider.value; if (checked) { blockUpdate = true; if (filter.animateIn > 0 || filter.animateOut > 0) { filter.resetProperty("yaw"); yawSlider.enabled = true; } filter.clearSimpleAnimation("yaw"); blockUpdate = false; filter.set("yaw", value, getPosition()); } else { filter.resetProperty("yaw"); filter.set("yaw", value); } } }
        UndoButton {
            id: yawUndo
            onClicked: yawSlider.value = 0
        }

        Label {
            text: qsTr('Pitch')
            Layout.alignment: Qt.AlignRight
        }
        SliderSpinner {
            id: pitchSlider
            minimumValue: -180
            maximumValue: 180
            spinnerWidth: 120; suffix: ' deg'; decimals: 3; stepSize: 1;
            onValueChanged: updateProperty_pitch(getPosition())
        }
        KeyframesButton { id: pitchKeyframesButton; checked: filter.animateIn <= 0 && filter.animateOut <= 0 && filter.keyframeCount("pitch") > 0; onToggled: { var value = pitchSlider.value; if (checked) { blockUpdate = true; if (filter.animateIn > 0 || filter.animateOut > 0) { filter.resetProperty("pitch"); pitchSlider.enabled = true; } filter.clearSimpleAnimation("pitch"); blockUpdate = false; filter.set("pitch", value, getPosition()); } else { filter.resetProperty("pitch"); filter.set("pitch", value); } } }
        UndoButton {
            id: pitchUndo
            onClicked: pitchSlider.value = 0
        }

        Label {
            text: qsTr('Roll')
            Layout.alignment: Qt.AlignRight
        }
        SliderSpinner {
            id: rollSlider
            minimumValue: -180
            maximumValue: 180
            spinnerWidth: 120; suffix: ' deg'; decimals: 3; stepSize: 1;
            onValueChanged: updateProperty_roll(getPosition())
        }
        KeyframesButton { id: rollKeyframesButton; checked: filter.animateIn <= 0 && filter.animateOut <= 0 && filter.keyframeCount("roll") > 0; onToggled: { var value = rollSlider.value; if (checked) { blockUpdate = true; if (filter.animateIn > 0 || filter.animateOut > 0) { filter.resetProperty("roll"); rollSlider.enabled = true; } filter.clearSimpleAnimation("roll"); blockUpdate = false; filter.set("roll", value, getPosition()); } else { filter.resetProperty("roll"); filter.set("roll", value); } } }
        UndoButton {
            id: rollUndo
            onClicked: rollSlider.value = 0
        }
        Item {
            Layout.fillHeight: true
        }

        Item {}
        CheckBox {
            text: qsTr('Show grid')
            checked: false
            id: gridCheckBox
            Layout.columnSpan: 3
            onCheckedChanged: updateProperty_grid()
        }
    }

    Connections {
        target: producer
        onPositionChanged: setControls()
    }
}
