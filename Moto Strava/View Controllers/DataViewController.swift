//
//  DataViewController.swift
//  Moto Strava
//
//  Created by Spencer DeBuf on 11/18/19.
//  Copyright © 2019 Spencer DeBuf. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreGPX

class DataViewController: UIViewController {
   
    /// the modelController that accesses the model
    var modelController: ModelController!
    
    /// the table view displaying all the tracks and the relevant information
    @IBOutlet private weak var courseTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseTableView.delegate = self
        courseTableView.dataSource = self
//        presentedViewController?.title = "Courses"
//        navigationController?.title = "Courses"
        title = "Courses"
        
//        importGPX()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        courseTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? EditCourseModelViewController {
            print("Destination as edit detail view controller")
            dest.courseID = modelController.courses[courseTableView.indexPathForSelectedRow!.row].uniqueIdentifier
//            dest.rowInModel = courseTableView.indexPathForSelectedRow!.row
            dest.modelController = modelController
        }
    }
    
    private func importGPX() {
        print("just before guard")
        guard let gpx = GPXParser(withRawString: GPX().gpx)?.parsedData() else {
            print("error")
            return
        }
        print("just after guard")
        
        print(gpx.waypoints.count)
        print(gpx.routes.count)
        print(gpx.tracks.count)
        
        print(gpx.tracks.first!.tracksegments.first!.trackpoints.count)
        
//        let track = SessionModel(withCoreGPX: gpx, withName: "test")
//        modelController.add(session: track, to: modelController.courses.first!)
        
//        modelController.add(at: 7, with: track)
    }
}

// MARK: - Table View Management

extension DataViewController: UITableViewDelegate, UITableViewDataSource {
    // deleting
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       if editingStyle == .delete {
        modelController.remove(course: modelController.courses[indexPath.row])
           courseTableView.reloadData()
       }
    }

    // number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelController.courses.count
    }

    // cell for row at
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = courseTableView.dequeueReusableCell(withIdentifier: "complexTrackCell", for: indexPath) as? TrackTableViewCell {
            
            //for convenience, we will be using this frequently in this function
            let thisCourse = modelController.courses[indexPath.row]
        
            //title
            cell.titleLabel.text = thisCourse.name

            // format and display the date
            let date = thisCourse.dateCreated
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: "en_US")
            cell.dateLabel.text = dateFormatter.string(from: date)
        
            EditDetailViewController.setPreviewImage(using: thisCourse.sessions) { image in cell.imageOutlet.image = image }
            
            let laps = thisCourse.totalLaps
            
            cell.lapsLabel.text = "Laps: \(laps)"
            
            cell.sessionsLabel.text = "Sessions: \(thisCourse.sessions.count)"
            
            cell.segmentsCompletedLabel.text = "Segments Completed: \(thisCourse.totalSegmentsCompleted)"
           
            return cell
       }
       
       // we didn't have a 'complexTrackCell', so we just create and return a new cell. I dont think this ever happens
       return UITableViewCell()
    }
}
