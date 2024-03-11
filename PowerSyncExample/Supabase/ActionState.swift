import CasePaths
import Foundation

@CasePathable
enum ActionState<Success, Failure: Error> {
  case idle
  case inFlight
  case result(Result<Success, Failure>)
}
