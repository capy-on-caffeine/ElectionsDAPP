import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Iter "mo:base/Iter";

actor Election {
  // type Buffer = Buffer.Buffer;
  type Result = Result.Result<(), Text>;

  type Person = {
    email : Text;
  };

  // can create separate types later eg. email : Email; type Email = Text;
  type Candidate = {
    email : Text;
    name : Text;
    speech : Text;
    var votes : Nat;
  };

  type Voter = {
    email : Text;
    hasVoted : Bool;
  };

  func personExistsElectionPool(e : Text) : Bool {
    for(p in electionPool.vals()) {
      if (p.email == e) return true;
    };
    return false;
  };

  func personExistsCandidates(e : Text) : Bool {
    for(p in candidates.vals()) {
      if (p.email == e) return true;
    };
    return false;
  };

  func personExistsVoters(e : Text) : Bool {
    for(p in voters.vals()) {
      if (p.email == e) return true;
    };
    return false;
  };

  func addPerson(e : Text) : Result {
    if (personExistsElectionPool(e)) {#err("Person already in election pool");}
    else {
      var person : Person = {email = e};
      electionPool.add(person);
      #ok();
    };
  };

  var candidates = Buffer.Buffer<Candidate>(5);
  var electionPool = Buffer.Buffer<Person>(5); // This is already filled, no one outside this list can vote, this should be branch specififc
  var voters = Buffer.Buffer<Voter>(5); //We could somehow combine this and electio pool + candidates too but let's figure that out later
  var a = addPerson("arnav@mail");
  var b = addPerson("chetan@mail");
  var c = addPerson("ekas@mail");
  var d = addPerson("ayush@mail");
  var e = addPerson("vanya@mail");

  public func addCandidate(e : Text, n : Text, s : Text) : async Text {
    // instead of () Result can be used too
    func checkValidityAndAdd() : Result {
      if (not personExistsElectionPool(e)) {#err("Person not in election pool");}
      else if (personExistsCandidates(e)) {#err("Person is already registered as a candidate");}
      else {
        var c : Candidate = {email = e; name = n; speech = s; var votes = 0};
        candidates.add(c);
        #ok();
      };
    };

    let result = checkValidityAndAdd();
    switch(result) {
      case(#ok()) {return "Candidate successfully added!"};
      case(#err(error)) {return error};
    };
  };

  public func vote(voterMail : Text, candidateMail : Text) : async Text {
      if (not personExistsElectionPool(voterMail)) {return "Person not in election pool";}
      else if (personExistsVoters(voterMail)) {return "Person has already voted";}
      else if (personExistsCandidates(voterMail)) {return "The person is an existing candidate";}
      else {
        for(c in candidates.vals()) {
          if (c.email == candidateMail) {
            c.votes += 1;
            var v : Voter = {email = voterMail; hasVoted = true};
            voters.add(v);
          }
        };
        // return "No such candidate found";
        return "Vote cast";
      };
    };

  public query func showResult() : async [(Text, Nat)] {
    var resultList = Buffer.Buffer<(Text, Nat)>(5);
    for(c in candidates.vals()) {
      resultList.add((c.name, c.votes));
    };
    Buffer.toArray(resultList);
  };
};