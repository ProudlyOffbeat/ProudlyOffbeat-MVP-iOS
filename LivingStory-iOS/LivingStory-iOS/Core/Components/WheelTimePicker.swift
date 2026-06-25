//
//  WheelTimePicker.swift
//  LivingStory-iOS
//
//  네이티브 휠(UIPickerView) 그대로의 시간 선택 + 행별 색상 제어.
//  선택(중앙) 행 = yellow60, 나머지 = #9E9E9E.
//  (UIDatePicker는 행별 색 분리가 불가해 UIPickerView로 구성)
//

import SwiftUI
import UIKit

struct WheelTimePicker: UIViewRepresentable {

    @Binding var time: Date

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        context.coordinator.picker = picker
        context.coordinator.select(time: time, animated: false)
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.timeBinding = $time
        if context.coordinator.currentDate() != time {
            context.coordinator.select(time: time, animated: false)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(time: $time) }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

        var timeBinding: Binding<Date>
        weak var picker: UIPickerView?

        private let hours = Array(1...12)
        private let minutes = Array(0...59)
        private let periods = ["AM", "PM"]
        // 컴포넌트별 선택 인덱스 (picker.selectedRow는 초기 타이밍상 부정확 → 직접 추적)
        private var selected: [Int] = [7, 0, 1]   // 시(8), 분(0), 오후

        init(time: Binding<Date>) { self.timeBinding = time }

        // 컴포넌트: 0=시, 1=분, 2=오전/오후
        func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0: return hours.count
            case 1: return minutes.count
            default: return periods.count
            }
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            component == 2 ? 66 : 52   // 컬럼 좁혀서 시·분·AM/PM 더 가깝게
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            40
        }

        func pickerView(_ pickerView: UIPickerView,
                        viewForRow row: Int,
                        forComponent component: Int,
                        reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            label.textAlignment = .center
            let isSelected = selected[component] == row
            label.font = .systemFont(ofSize: 26, weight: isSelected ? .semibold : .regular)
            label.textColor = isSelected
                ? (UIColor(named: "yellow60") ?? .systemYellow)   // 선택: 쨍한 노랑 + semibold
                : UIColor(hex: 0x9E9E9E)                          // 나머지

            switch component {
            case 0: label.text = "\(hours[row])"
            case 1: label.text = String(format: "%02d", minutes[row])
            default: label.text = periods[row]
            }
            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selected[component] = row
            timeBinding.wrappedValue = currentDate()
            pickerView.reloadComponent(component)   // 중앙 행 색 갱신
        }

        // MARK: - Date 변환

        func currentDate() -> Date {
            let hour12 = hours[selected[0]]
            let minute = minutes[selected[1]]
            let isPM = selected[2] == 1
            var hour24 = hour12 % 12
            if isPM { hour24 += 12 }
            return Calendar.current.date(
                bySettingHour: hour24, minute: minute, second: 0,
                of: timeBinding.wrappedValue
            ) ?? timeBinding.wrappedValue
        }

        func select(time: Date, animated: Bool) {
            guard let picker else { return }
            let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
            let h24 = comps.hour ?? 20
            let isPM = h24 >= 12
            let h12 = (h24 % 12 == 0) ? 12 : h24 % 12
            selected = [hours.firstIndex(of: h12) ?? 7, comps.minute ?? 0, isPM ? 1 : 0]
            picker.selectRow(selected[0], inComponent: 0, animated: animated)
            picker.selectRow(selected[1], inComponent: 1, animated: animated)
            picker.selectRow(selected[2], inComponent: 2, animated: animated)
            picker.reloadAllComponents()
        }
    }
}
