class LoginEvent {
  String username;

  LoginEvent(this.username);
}

class LogoutEvent {
}

class CollectEvent {
  int id;
  bool collect;

  CollectEvent(this.id, this.collect);

}
