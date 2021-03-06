//
//  ModelController.swift
//  Moto Strava
//
//  Created by Spencer DeBuf on 11/24/19.
//  Copyright © 2019 Spencer DeBuf. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class ModelController {
    private var model = MotosModel()

    var courses: [CourseModel] { return model.courses }
    
    init() {
        loadModelFromJSON()
    }
    
    var allSessions: [SessionModel] {
        var sessions = [SessionModel]()
        for course in courses { sessions.append(contentsOf: course.sessions) }
        return sessions
    }
    
    private func saveJSONToFile() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let json = self.model.json {
                if let url = try? FileManager.default.url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true).appendingPathComponent("motoStravaModelThree.json") {
                    do {
                        try json.write(to: url)
                        print("saved successfully!")
                    } catch let error {
                        print("couldn't save \(error)")
                    }
                }
            }
        }
    }
    
    private func loadModelFromJSON() {
        if let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true).appendingPathComponent("motoStravaModelThree.json")
        {
            if let jsonData = try? Data(contentsOf: url) {
                if let msm = MotosModel(withJSON: jsonData) {
                    model = msm
                    print("loaded sucessfully!")
                } else {
                    model = MotosModel()
                    print("couldn't load from Data") 
                }
            } else { print("couldn't load from Data") }
        } else { print("couldn't load from URL") }
    }
    
    func course(with id: Int) -> CourseModel? {
        return courses.first(where: { $0.uniqueIdentifier == id } )
    }
    
    func session(inCourse: CourseModel, withSessionID: Int) -> SessionModel? {
        return inCourse.sessions.first(where: { $0.uniqueIdentifier == withSessionID })
    }
    
//     let track = SessionModel(withCLLocationArray: currentLocationList, withName: currentLocationList.first!.timestamp.description)
    
    func createSession(withCLLocationArray: [CLLocation], withName: String) -> SessionModel {
        let session = SessionModel(withCLLocationArray: withCLLocationArray, withName: withName, with: model.getNextSessionID())
        return session
    }
    
//    let newSessionModel = CourseModel(usingInitialSession: track)

    
    func createCourse(usingIntialSession: SessionModel) -> CourseModel {
        let course = CourseModel(usingInitialSession: usingIntialSession, with: model.getNextCourseID())
        return course
    }
    
    func remove(course: CourseModel) {
        if let courseIndex = courses.firstIndex(of: course) {
            model.courses.remove(at: courseIndex)
            saveJSONToFile()
        } else { print("error removing course, course not found") }
    }
    
    func remove(session: SessionModel, from course: CourseModel) {
        if let courseIndex = courses.firstIndex(of: course) {
            if let sessionIndex = courses[courseIndex].sessions.firstIndex(of: session) {
                model.courses[courseIndex].sessions.remove(at: sessionIndex)
                saveJSONToFile()
            } else { print("error removing session, session not found") }
        } else { print("error removing session, course not found") }
    }
    
//    func removeSession(fromSessionModelNumber sessionModel: Int, atSession session: Int) {
//        motoStravaModel.courses[sessionModel].sessions.remove(at: session)
//        saveJSONToFile()
//    }
    
//    func trackNameForRow(at index: Int) -> String {
//        return motoStravaModel.listOfTracks[index].name
//    }
    
    func add(course: CourseModel) {
        model.courses.append(course)
        saveJSONToFile()
    }
    
//    func dateForRow(at index: Int) -> Date {
//        return motoStravaModel.listOfTracks[index].timeStamp
//    }
    
//    func sessionForRow(at index: Int) -> SessionsModel {
//        return motoStravaModel.listOfTracks[index]
//    }
    
//    func distanceForRow(at index: Int) -> Double {
//        let track = motoStravaModel.listOfTracks[index]
//        var distance = 0.0
//        var previousLocation: CLLocation?
//        for location in track.locations {
//            if previousLocation == nil {
//                previousLocation = location
//                continue
//            }
//            distance += location.distance(from: previousLocation!)
//            previousLocation = location
//        }
//        return distance
//    }
    
    func editName(for course: CourseModel, with name: String) {
        if let courseIndex = courses.firstIndex(of: course) {
            model.courses[courseIndex].name = name
            saveJSONToFile()
        } else { print("error changing name, course not found") }
    }
    
//    func editName(at index: Int, with name: String) {
//        motoStravaModel.courses[index].name = name
//        saveJSONToFile()
//    }
    
//    func editColorForRow(at index: Int, with color: UIColor) {
//        motoStravaModel.listOfTracks[index].color = color
//        saveJSONToFile()
//    }
    
    func setLapGate(for course: CourseModel, with lapGate: GateModel) {
        if let courseIndex = model.courses.firstIndex(of: course) {
            model.courses[courseIndex].lapGate = lapGate
            saveJSONToFile()
        } else { print("error setting lap gate, course not found") }
    }
    
//    func setLapGate(at index: Int, with lapGate: GateModel) {
//        motoStravaModel.courses[index].lapGate = lapGate
//        saveJSONToFile()
////        print("allegedly saved lapgate \(Date().timeIntervalSince1970)")
//    }
    
    func add(session: SessionModel, to course: CourseModel) {
        if let courseIndex = model.courses.firstIndex(of: course) {
            model.courses[courseIndex].sessions.append(session)
            saveJSONToFile()
        }
    }
    
//    func add(at index: Int, with session: SessionModel) {
//        motoStravaModel.courses[index].sessions.append(session)
//        saveJSONToFile()
//    }
//
    
    func setColorForSession(in course: CourseModel, for session: SessionModel, with color: UIColor) {
        if let courseIndex = model.courses.firstIndex(of: course) {
            if let sessionIndex = model.courses[courseIndex].sessions.firstIndex(of: session) {
                model.courses[courseIndex].sessions[sessionIndex].color = color
                saveJSONToFile()
            } else { print("error setting session color, session not found") }
        } else { print("error setting session color, course not found") }
    }
    
    
//    func setColorForSession(sessionModelIndex: Int, sessionIndex: Int, with color: UIColor) {
//        motoStravaModel.courses[sessionModelIndex].sessions[sessionIndex].color = color
//        saveJSONToFile()
//    }
    
    
    func editNameForSession(in course: CourseModel, session: SessionModel, with newName: String) {
        if let courseIndex = model.courses.firstIndex(of: course) {
            if let sessionIndex = model.courses[courseIndex].sessions.firstIndex(of: session) {
                model.courses[courseIndex].sessions[sessionIndex].name = newName
                saveJSONToFile()
            } else { print("error editing session name, session not found") }
        } else { print("error editing session name, course not found") }
    }
    
//    func editNameForSession(sessionModelIndex: Int, sessionIndex: Int, with newName: String) {
//        motoStravaModel.courses[sessionModelIndex].sessions[sessionIndex].name = newName
//        saveJSONToFile()
//    }
    
    func addSectionGate(to course: CourseModel, startGate: GateModel, endGate: GateModel) {
        if let courseIndex = model.courses.firstIndex(of: course) {
            model.courses[courseIndex].addSectionGates(startGate: startGate, stopGate: endGate)
            saveJSONToFile()
        } else {
            print("Error deleting section from course, course not found")
        }
    }
    
//    func addSectionGate(sessionModelIndex: Int, startGate: GateModel, endGate: GateModel) {
//        motoStravaModel.listOfTracks[sessionModelIndex].addSectionGates(startGate: startGate, stopGate: endGate)
//        saveJSONToFile()
//    }
    
    func replaceSectionGate(in course: CourseModel, replace original: (GateModel, GateModel), with replacement: (GateModel, GateModel)) {
        if let courseIndex = model.courses.firstIndex(of: course) {
            if let sectionIndex = model.courses[courseIndex].firstIndexOf(startGate: original.0, stopGate: original.1) {
                model.courses[courseIndex].replaceSectionGates(sectionIndex: sectionIndex, startGate: replacement.0, stopGate: replacement.1)
                saveJSONToFile()
            } else {
                print("error replacing section, section index not found")
            }
        } else {
            print("error replacing section, course not found")
        }
        
    }
    
//    func replaceSectionGate(sessionModelIndex: Int, sectionIndex: Int, startGate: GateModel, endGate: GateModel) {
//        motoStravaModel.listOfTracks[sessionModelIndex].replaceSectionGates(sectionIndex: sectionIndex, startGate: startGate, stopGate: endGate)
//        saveJSONToFile()
//    }
    
    func removeSectionGate(from course: CourseModel, section: (GateModel, GateModel)) {
        if let courseIndex = model.courses.firstIndex(of: course) {
            if let sectionIndex = model.courses[courseIndex].firstIndexOf(startGate: section.0, stopGate: section.1) {
                model.courses[courseIndex].removeSection(at: sectionIndex)
                saveJSONToFile()
            } else {
                print("error deleting section from course, section not in course ")
            }
        } else {
            print("Error deleting section from course, course not in model")
        }
    }
    
    func addLocation(course: CourseModel, session: SessionModel, location: CLLocation) {
        if let courseIndex = model.courses.firstIndex(of: course) {
            if let sessionIndex = model.courses[courseIndex].sessions.firstIndex(of: session) {
                model.courses[courseIndex].sessions[sessionIndex].add(newLocation: location)
                saveJSONToFile()
            } else {
                print("error adding location, section not in course ")
            }
        } else {
            print("Error adding location, course not in model")
        }
    }
}
