
import UIKit

//this code is a simplified version of functionality that searches a database for data, returns that data, and then updates the buttons with an image based on if people completed their fitness goals or not. the problem that was faced while programming this code is that the returned json comes back in a very disorganized fashion. The extension below was created to reorganize the data in a way that made sense, and update buttons with a white check mark if a user completed their fitness goals or not.

class NutritionViewController: UIViewController {
    
    //our buttons that will be updated. if a user completes their goal of eating enough food for the day, the button's image will change to a white check mark.
    
    let monday:UIButton! = UIButton()
    let tuesday: UIButton! = UIButton()
    let wednesday:UIButton! = UIButton()
    let thursday:UIButton! = UIButton()
    let friday:UIButton! = UIButton()
    let saturday:UIButton! = UIButton()
    let sunday:UIButton! = UIButton()
    
    var protocolCalories: Int? = 2000 // this is a user's calorie goal. to simplify this instance of functionality, a user must eat 2000 calories a day
    
    var currentDayTag = 11 // the tag associated with the buttons. see below for which day equals which tag. for this example the current day is monday
    
    // tags: monday 11 // tuesday 12 // wednesday 13 // thursday 14 // friday 15 // saturday 16 // sunday 17
    
}

extension NutritionViewController {
    
    func updateViewsWithData(delta delta: Int, json: [[String:AnyObject]]) {
        
        let delta = delta
        
        let foodEntries = json // the json that comes back are the
        
        guard let protocolCalories = self.protocolCalories else { return } // make sure the users do have a goal based on their fitness program. this value has a chance to be optional
        
        var week = [Int: Int]() // create a dictionary where we can store the values in an ordered fashion
        
        for foodEntry in foodEntries { // loop through the foodEntries
            
            if let food = foodEntry["food_entry"] as? [[String:AnyObject]]  {
                
                for food_item in food { // look at the different food items
                    
                    guard let calories = food_item["calories"] as? String else { return } // find the calories
                    
                    
                    guard let date_int = food_item["date_int"] as? String else { return } // finding the day associated with that food entry. these days are based on days since Jan 1 1970.
                    
                    guard let dubCalories = Double(calories) else { return }
                    let _calories = Int(dubCalories)
                    
                    guard let dubDateInt = Double(date_int) else { return }
                    
                    let _date_int = Int(dubDateInt) // converting day from a string to a double, and now an int
                    
                    if week.isEmpty { week[_date_int] = _calories // add our first entry if empty
                        
                    } else if week[_date_int] == nil { week[_date_int] = _calories // if a date entry has not been detected, create one
                        
                    } else if week[_date_int] != nil { week[_date_int] = week[_date_int]! + _calories // if a date entry aleady exists, add more calories for that associated day
                        
                    }
                    
                    
                }
                
            } else if let food = foodEntry["food_entry"] as? [String:AnyObject] { // we occcassionally run into a situation where a user has only entered one food entry for a day. so we hace to account for this here
                
                guard let calories = food["calories"] as? String else { return } // get calories. same as above. (string)
                
                guard let date_int = food["date_int"] as? String else { return } // get the current date. same as above (string)
                
                guard let dubCalories = Double(calories) else { return }
                let _calories = Int(dubCalories)
                
                guard let dubDateInt = Double(date_int) else { return }
                
                let _date_int = Int(dubDateInt)
                
                if week.isEmpty { week[_date_int] = _calories // same as above
                    
                } else if week[_date_int] == nil { week[_date_int] = _calories // same. see above.
                    
                } else if week[_date_int] != nil { week[_date_int] = week[_date_int]! + _calories //same
                    
                }
                
            } else if foodEntry["food_entry"] == nil {
                
                continue // there might not be any food entries. so just continue
                
            }
            
        }
        
        var buttonDayPair = [UIButton:Int]() //this is important. one of the problems is that depending on what day of the week the user opens the app, we have to account for what day the user opened the app
        
        let sortedWeek = week.sort {$0.0 < $1.0} //sort the week. this actually isn't necessary, but makes the data a little more organizable and readable for print statements if you choose to log information to the console
        
        let currentDayTag = self.currentDayTag //
        
        let currentDay = getCurrentDay() // we get the current day as a measure of days since 1 Jan 1970
        
        let views = [ monday, tuesday, wednesday, thursday, friday, saturday, sunday ] //an array of our buttons
        
        switch currentDayTag { // based on what day the user opens the app, we want to match up the buttons relative to the current day that they opened up the app. so that the appropriate check mark gets loaded onto that day and not the wrong one
            
        case 11: //monday
            buttonDayPair[monday] = currentDay
            
        case 12: // tuesday
            
            buttonDayPair[tuesday] = currentDay
            buttonDayPair[monday] = currentDay - 1
            
        case 13: // wednesday
            buttonDayPair[wednesday] = currentDay
            buttonDayPair[tuesday] = currentDay - 1
            buttonDayPair[monday] = currentDay - 2
            
        case 14: //thursday
            buttonDayPair[thursday] = currentDay
            buttonDayPair[wednesday] = currentDay - 1
            buttonDayPair[tuesday] = currentDay - 2
            buttonDayPair[monday] = currentDay - 3
            
        case 15: // friday
            buttonDayPair[friday] = currentDay
            buttonDayPair[thursday] = currentDay - 1
            buttonDayPair[wednesday] = currentDay - 2
            buttonDayPair[tuesday] = currentDay - 3
            buttonDayPair[monday] = currentDay - 4
            
        case 16: // saturday
            buttonDayPair[saturday] = currentDay
            buttonDayPair[friday] = currentDay - 1
            buttonDayPair[thursday] = currentDay - 2
            buttonDayPair[wednesday] = currentDay - 3
            buttonDayPair[tuesday] = currentDay - 4
            buttonDayPair[monday] = currentDay - 5
            
        case 17: // sunday
            buttonDayPair[sunday] = currentDay
            buttonDayPair[saturday] = currentDay - 1
            buttonDayPair[friday] = currentDay - 2
            buttonDayPair[thursday] = currentDay - 3
            buttonDayPair[wednesday] = currentDay - 4
            buttonDayPair[tuesday] = currentDay - 5
            buttonDayPair[monday] = currentDay - 6
            
        default:
            print("error") // obviously we have an error if its not able to see the current day
        }
        
        guard let completionImg = UIImage(named: "CheckMarkWhite") else { return } //find our checkmark image
        
        for entry in buttonDayPair {
            
            for day in sortedWeek {
                if day.0 == entry.1 && day.1 >= protocolCalories { entry.0.setImage(completionImg, forState: .Normal) }
                //for each day in our week, if the fvalue of our calories entry is greater than or equal to our protocol entry, turn the button image into a white check mark
                
            }
            
        }
        
    }
    
}

extension UIViewController {
    
    //returns the current day as a measure of secondsFromGMT. gets it from seconds since 1970 and then converts that to a day
    func getCurrentDay() -> Int {
        
        let date = NSDate() //UTC
        
        let UTCseconds = Int(date.timeIntervalSince1970)
        let timeZoneSeconds = NSTimeZone.localTimeZone().secondsFromGMT // get seconds difference from GMT
        
        let finalSeconds = UTCseconds + timeZoneSeconds
        
        let hour = finalSeconds / 3600 ; let day = hour / 24
        
        return day
        
    }
    
}

