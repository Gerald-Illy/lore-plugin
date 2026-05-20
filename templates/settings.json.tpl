{
  "permissions": {
    "allow": [
      "Bash(git -C {REPO_PATH} pull*)",
      "Bash(git -C {REPO_PATH} fetch*)",
      "Bash(git -C {REPO_PATH} merge*)",
      "Bash(git -C {REPO_PATH} add*)",
      "Bash(git -C {REPO_PATH} commit*)",
      "Bash(git -C {REPO_PATH} push*)",
      "Bash(git -C {REPO_PATH} rev-parse*)",
      "Bash(git -C {REPO_PATH} log*)",
      "Bash(cd {REPO_PATH}*)",
      "Bash(test -d {REPO_PATH}*)",
      "Bash(test -f {REPO_PATH}*)",
      "Bash(cat {REPO_PATH}*)"
    ]
  }
}
