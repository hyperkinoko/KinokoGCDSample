//
//  ViewController.swift
//  KinokoGCDSample
//
//  Created by superkinoko on 2017/03/08.
//  Copyright © 2017年 kinokodata. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 時間のかかる処理
    func doSomething(number: Int) {
        print("Task \(number): Start")
        for i in 0 ... 10 {
            sleep(1)
            print("Task \(number): Running ... \(i * 10)%")
        }
        print("Task \(number): Completed")
    }
    
    // すべて直列で処理
    func inMainQueueOnly() {
        for i in 1 ... 3 {
            doSomething(number: i)
        }
        print("All tasks completed.")
    }
    
    // キューを並列で処理
    func inConcurrentQueue() {
        for i in 1 ... 3 {
            DispatchQueue.global(qos: .default).async {
                self.doSomething(number: i)
            }
        }
        print("ここはキューの処理完了を待たずに実行される")
    }
    
    // 複数のキューを並列処理した後に、さらに処理を行う
    func doMoreAfterConcurretQueuesUsingDispatchGroup() {
        let group = DispatchGroup()
        
        for i in 1 ... 3 {
            group.enter()
            DispatchQueue.global(qos: .default).async {
                self.doSomething(number: i)
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global(qos: .default)) {
            print("すべてのキューの処理が完了しました")
        }
    }
    
    // 並列処理した後に値を返す
    // このように書きたいところだが、これは構文として正しくない
    /*func returnsValueAfterConcurretQueuesUsingDispatchGroup() -> String {
        var string = "初期値"
        let group = DispatchGroup()

        for i in 1 ... 3 {
            group.enter()
            DispatchQueue.global(qos: .default).async {
                self.doSomething(number: i)
                string += " => Task\(i)が終了"
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global(qos: .default)) {
            return string
        }
    }*/

    // 何か処理した後に値を返す（セマフォを使用）
    func returnsValueAfterAQueueUsingSemaphore() -> String {
        var string = "初期値"
        let semaphore = DispatchSemaphore(value: 0)

        DispatchQueue.global(qos: .default).async {
            self.doSomething(number: 1)
            string += " => Task1が終了"
            semaphore.signal()
        }
        
        semaphore.wait()
        return string
    }
    
    // キューを並列処理した後に値を返す（セマフォを使用）
    func returnsValueAfterConcurrentQueuesUsingSemaphore() -> String {
        var string = "初期値"
        let semaphore = DispatchSemaphore(value: 0)
        
        for i in 1 ... 3 {
            DispatchQueue.global(qos: .default).async {
                self.doSomething(number: i)
                string += " => Task\(i)が終了"
                semaphore.signal()
            }
        }
        
        for _ in 1 ... 3 {
            semaphore.wait()
        }
        return string
    }
    
    @IBAction func onButton1Tapped(_ sender: Any) {
        inMainQueueOnly()
    }
    
    @IBAction func onButton2Tapped(_ sender: Any) {
        inConcurrentQueue()
    }
    
    @IBAction func onButton3Tapped(_ sender: Any) {
        doMoreAfterConcurretQueuesUsingDispatchGroup()
    }
    
    @IBAction func onButton4Tapped(_ sender: Any) {
        print(returnsValueAfterAQueueUsingSemaphore())
    }
    
    @IBAction func onButton5Tapped(_ sender: Any) {
        print(returnsValueAfterConcurrentQueuesUsingSemaphore())
    }
}

