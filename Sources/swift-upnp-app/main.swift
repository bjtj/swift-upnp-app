import Foundation
import SwiftUpnpTools

struct Session {
    var device: UPnPDevice?
    var service: UPnPService?
}

func main() {

    var session = Session()

    var done = false

    let cp = UPnPControlPoint(port: 0)
    cp.run()

    cp.onDeviceAdded {
        (device) in
        print("device added -- \(device.udn ?? "nil") / \(device.friendlyName ?? "nil")")
    }

    cp.onDeviceRemoved {
        (device) in
        print("device removed -- \(device.udn ?? "nil") / \(device.friendlyName ?? "nil")")
    }

    cp.onEventProperty {
        (sid, properties) in
        print("event notify -- sid: \(sid)")
        for field in properties.fields {
            print("- \(field.key): \(field.value ?? "nil")")
        }
    }

    while done == false {
        guard let line = readLine() else {
            continue
        }
        let tokens = line.split(separator: " ", maxSplits: 1).map { String($0) }
        guard tokens.isEmpty == false else {
            print(" == session ==")
            guard let device = session.device else {
                print("device is not selected")
                continue
            }
            print("device -- \(device.udn ?? "nil") \(device.friendlyName ?? "nil")")
            for service in device.services {
                print(" - \(service.serviceType ?? "nil")")
            }
            guard let service = session.service else {
                print("service is not selected")
                continue
            }
            print("service -- \(service.serviceType ?? "nil")")
            continue
        }
        switch tokens[0] {
        case "quit", "q":
            done = true
            break
        case "search":
            cp.sendMsearch(st: tokens[1], mx: 3)
        case "ls":
            print(" == devices (count: \(cp.devices.count)) ==")
            for device in cp.devices {
                print("* \(device.udn ?? "nil") -- \(device.friendlyName ?? "nil")")
            }
        case "device":
            guard let idx = Int(tokens[1]) else {
                print("not integer")
                continue
            }
            guard idx >= 0 && idx < cp.devices.count else {
                print("not in range")
                continue
            }
            let device = cp.devices[idx]
            print("idx: \(idx) -- \(device.udn ?? "nil") \(device.friendlyName ?? "nil")")
            for service in device.services {
                print(" - service: \(service.serviceType ?? "nil")")
            }
            session.device = device
        case "service":
            guard let device = session.device else {
                print("device is not selected")
                continue
            }
            let serviceType = tokens[1]
            guard let service = device.getService(type: serviceType) else {
                print("no service found -- \(serviceType)")
                continue
            }
            session.service = service
            print("selected service id -- \(service.serviceId ?? "nil")")
            guard let scpd = service.scpd else {
                print("no scpd")
                continue
            }
            for action in scpd.actions {
                print("- action: \(action.name ?? "nil")")
            }
        case "invoke":
            guard tokens.count > 1 else {
                print("action name is required")
                continue
            }
            guard let service = session.service else {
                print("service is not selected")
                continue
            }
            guard let scpd = service.scpd else {
                print("service has no scpd")
                continue
            }
            guard let action = scpd.getAction(name: tokens[1]) else {
                print("no action name -- \(tokens[1])")
                continue
            }
            var properties = [String:String]()
            for argument in action.inArguments {
                guard let name = argument.name else {
                    continue
                }
                print("- in argument: \(name)")
                guard let argumentValue = readLine() else {
                    print("failed to read argument value")
                    return
                }
                properties[name] = argumentValue
            }
            cp.invoke(service: service, action: action, properties: properties) {
                (soapResponse) in
                guard let soapResponse = soapResponse else {
                    print("no soap response")
                    return
                }
                print("action response")
                for field in soapResponse.fields {
                    print("- \(field.key): \(field.literalValue)")
                }
            }
        case "subscribe":
            guard let service = session.service else {
                print("service is not selected")
                continue
            }
            cp.subscribe(service: service) {
                (subscription) in
                print("subscribe is done -- \(subscription.sid)")
            }
        default:
            print("unknown command -- \(tokens[0])")
        }
    }

    cp.finish()
}

main()
