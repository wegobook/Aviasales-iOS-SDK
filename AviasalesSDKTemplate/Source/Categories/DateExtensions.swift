@objc extension NSDate {

    func hour() -> Int {
        let calendar = HDKDateUtil.sharedCalendar
        let components = calendar.dateComponents(Set([Calendar.Component.hour]), from: self as Date)
        return components.hour!
    }

    func minute() -> Int {
        let calendar = HDKDateUtil.sharedCalendar
        let components = calendar.dateComponents(Set([Calendar.Component.minute]), from: self as Date)
        return components.minute!
    }

    func second() -> Int {
        let calendar = HDKDateUtil.sharedCalendar
        let components = calendar.dateComponents(Set([Calendar.Component.second]), from: self as Date)
        return components.second!
    }

}
