//
//  EditDetailViewController.swift
//  Moto Strava
//
//  Created by Spencer DeBuf on 11/25/19.
//  Copyright © 2019 Spencer DeBuf. All rights reserved.
//

import UIKit
import MapKit

class EditDetailViewController: UIViewController {
    /// default colors for the picker
    static var defaultColors: [UIColor] {
        return [.black, .blue, .brown, .cyan, .darkGray, .gray, .green, .lightGray, .magenta, .orange, .purple, .red, .white, .yellow]
    }
    
    private var cell: ImageViewTableViewCell!
    private var textField: UITextField!
    
    private var tableViewHasReloadedData = false
    
    var course: CourseModel! { return modelController.course(with: courseID) }
//    var session: SessionModel { return course.sessions[trackInSessions] }
    
    /// the names associated with the default colors for the picker
    static var defaultColorNames: [String] {
        return ["black", "blue", "brown", "cyan", "dark Gray", "gray", "green", "light Gray", "magenta", "orange", "purple", "red", "white", "yellow"]
    }
    
    /// these are set when this VC is segued to
//    var rowInModel: Int!
    var courseID: Int!
    var modelController: ModelController!
    var sessionID: Int!
//    var trackInSessions: Int!
    
    var session: SessionModel! { return modelController.session(inCourse: course, withSessionID: sessionID) }
    
    /// the color picker for track color
    private let colorPicker = UIPickerView()
    
    let toolBar = UIToolbar()

    // IBOutlets
    @IBOutlet var editDetailTableView: UITableView!
    
    /// prints out gpx data to console
    @IBAction private func shareButtonPressed(_ sender: UIBarButtonItem) {
        print(session.gpxString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Session"
        colorPicker.dataSource = self
        colorPicker.delegate = self
        
        editDetailTableView.delegate = self
        editDetailTableView.dataSource = self
        
        colorPicker.dataSource = self
        colorPicker.delegate = self
        
        // create a toolbar for the pickers (so 'done' can be chosen)
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        // add buttons to the toolBar
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        //updateViewFromModel()
        
//        let (start, stop) = modelController.listOfSessions[rowInModel].sectionGates.last!
//        let times = currentTrack.getSectionTimes(usingStartGate: start, stopGate: stop)
//        print(times)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        editDetailTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // track preview
        if let mapPreview = segue.destination as? TrackPreviewViewController {
//            mapPreview.locationList = [session.locations]
//            mapPreview.trackColor = [session.color]
//            mapPreview.lapGate = course.lapGate
            mapPreview.modelController = modelController
            mapPreview.courseID = courseID
            mapPreview.sessionID = sessionID
//            mapPreview.rowInModel = rowInModel
        }
    }
    
    /// actions to be taken when the 'done' button in the picker toolbar is pressed, just resign the picker as firstResponder
    @objc func donePicker() {
        textField.resignFirstResponder()
    }
    
//    /// updates the tableview data from the model
//    private func updateViewFromModel() {
//        editDetailTableView.reloadData()
//    }
    
    static func setPreviewImage(using sessions: [SessionModel], onCompletionExecute completionClosure: @escaping (UIImage) -> Void) {
        // update the track image preview
        var previewImage = UIImage()
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion.mapRegion(using: sessions.first!.locations)
        options.mapType = .satellite
        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.start() { (snapshot, error) in
            if snapshot != nil {
                previewImage = snapshot!.image
                for sess in sessions {
                    let locationPoints = sess.locations.map() { $0.coordinate }
                    let cgPoints = locationPoints.map { snapshot!.point(for: $0) }
                    previewImage = UIImage.drawLines(using: cgPoints, on: previewImage, with: sess.color)!
                }
                completionClosure(previewImage)
                
            } else {
                print("Snapshot == nil")
                previewImage = snapshot!.image
                completionClosure(previewImage)
            }
        }
    }
}

extension EditDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // number of components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // number of rows in component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Self.defaultColors.count
    }
    
    // title for row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Self.defaultColorNames[row].capitalized
    }
    
    // did select row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        modelController.setColorForSession(in: course, for: session, with: Self.defaultColors[row])
//        modelController.setColorForSession(sessionModelIndex: rowInModel, sessionIndex: trackInSessions, with: Self.defaultColors[row])
//        updateViewFromModel()
        EditDetailViewController.setPreviewImage(using: [session]) { image in
            self.cell.customImageView.image = image
        }
    }
}

extension EditDetailViewController: UITextFieldDelegate {
    
    // text field should return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        modelController.editNameForSession(in: course, session: session, with: textField.text!)
//        modelController.editNameForSession(sessionModelIndex: rowInModel, sessionIndex: trackInSessions, with: textField.text!)
        return true
    }
}

extension EditDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 9 }
        else if section == 1 { return session.getLapTimes(usingLapGate: course.lapGate).count}
        else if section > 1 {
            let (start, stop) = course.sectionGates[section - 2]
            return session.getSectionTimes(usingStartGate: start, stopGate: stop).count
        }
        
        print("error in number of rows in section of edit detail")
        return -1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                if let cell = editDetailTableView.dequeueReusableCell(withIdentifier: "sessionNameCell", for: indexPath) as? EditNameTableViewCell {
                    cell.titleTextField.text = session.name
                    cell.titleTextField.delegate = self
                    return cell
                }
            case 1:
                if let cell = editDetailTableView.dequeueReusableCell(withIdentifier: "mapPreviewCell", for: indexPath) as? ImageViewTableViewCell {
                    self.cell = cell
                    
                    EditDetailViewController.setPreviewImage(using: [session]) { image in
                        cell.customImageView.image = image
                        
                        if !self.tableViewHasReloadedData {
                            self.tableViewHasReloadedData = true
                            self.editDetailTableView.reloadData()
                        }
                    }
                    return cell
                }
            case 2:
                let cell = editDetailTableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
                // update the date label
                let date = session.timeStamp
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .full
                dateFormatter.timeStyle = .short
                dateFormatter.locale = Locale(identifier: "en_US")
                cell.textLabel!.text = dateFormatter.string(from: date)
                return cell
            case 3:
                let cell = editDetailTableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
                // update the distance label
                cell.textLabel!.text = "\(session.trackDistance.easyToReadNotation(withDecimalPlaces: 3)) miles"
                return cell
            case 4:
                let cell = editDetailTableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
                // update the average speed label
                cell.textLabel!.text = "Avg speed: \(session.averageSpeed.easyToReadNotation(withDecimalPlaces: 3)) mph"
                return cell
            case 5:
               let cell = editDetailTableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
               // update the duration label
               // update the duration
//               let (hours, minutes, seconds, _) = currentTrack.duration.timeIntervalToHoursMinutesSeconds()
               cell.textLabel!.text = "Duration: \(session.duration.toStringAppropriateForLapTime(withDecimalPlaces: 0))"
                return cell
            case 6:
                let cell = editDetailTableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
                // update the Max Elevation
                let bestTime = session.getBestLapTime(usingLapGate: course.lapGate)
                let bestTimeString = bestTime != nil ? bestTime!.toStringAppropriateForLapTime(withDecimalPlaces: 2) : "NA"
                cell.textLabel!.text = "Best Lap Time: \(bestTimeString)"
                return cell
            case 7:
                let cell = editDetailTableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
                // update the Max Elevation
                let maxElevation = (session.maxAltitude).customRounded(withDecimalPlaces: 0)
                cell.textLabel!.text = "Max Elevation: \(maxElevation)"
                return cell
            case 8:
                 if let cell = editDetailTableView.dequeueReusableCell(withIdentifier: "editTrackColorCell", for: indexPath) as? EditTrackColorTableViewCell {
                    self.textField = cell.trackColorTextField
                     cell.trackColorTextField.text = "Edit Track Color"
                    
                    // create a toolbar for the pickers (so 'done' can be chosen)
                    cell.trackColorTextField.delegate = self
                    cell.trackColorTextField.inputView = colorPicker
                    cell.trackColorTextField.inputAccessoryView = toolBar
                    return cell
                }
            default:
                return UITableViewCell()
            }
        }
        else if indexPath.section == 1 {
            let cell = editDetailTableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
           
            let lapTimes = session.getLapTimes(usingLapGate: course.lapGate)
            print (indexPath.row)
            cell.textLabel!.text = "Lap \(indexPath.row + 1):    \(lapTimes[indexPath.row].toStringAppropriateForLapTime(withDecimalPlaces: 2))"
            return cell
        }
        
        else if indexPath.section > 1 {
            let cell = editDetailTableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
            let (start, stop) = course.sectionGates[indexPath.section - 2]
            let segmentTimes = session.getSectionTimes(usingStartGate: start, stopGate: stop)
            //print (indexPath.row)
            cell.textLabel!.text = "Run \(indexPath.row + 1): \(segmentTimes[indexPath.row].toStringAppropriateForLapTime(withDecimalPlaces: 2))"
            return cell
        }
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + course.sectionGates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 { return "Laps" }
        else if section == 0 { return "Session Data" }
        else if section >= 2 && section < 2 + course.sectionGates.count {
            return "Section \(section - 1)"
        }
        else { return "error" }
    }
}
