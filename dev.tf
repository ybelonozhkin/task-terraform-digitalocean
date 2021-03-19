variable "devs" {
  type = map(any)
  default = {
    ybelonozhkin = ["lb", "app1", "app2"],
    someuser     = ["dbserver", "app-test", "proxy"]
  }
}
