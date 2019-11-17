class User {
  String username;
  String email;
  String password;
  String imageUrl;

  setData(username, email, pass, imageUrl) {
    this.email = email;
    this.username = username;
    this.password = pass;
    this.imageUrl = imageUrl;
  }

  signOut() {
    username = null;
    email = null;
    password = null;
    imageUrl = null;
  }

  bool isLoggedIn() {
    return (username != null && email != null && password != null);
  }
}
