unit "k0s-containers" {
  source = "../../units/lxc"
  path   = "lxc"

  values = {
    version        = "HEAD"
    desired_count  = 5

    target_node    = "node-1"
    host_prefix    = "k0s"
    ipv4_ip_start  = 100
    ssh_public_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrbzy02WnDwoYuJuf/9t/DVOHqtXpsESLhmplbUnQ1dUcko3++kqO1zpFP2hq/RRhhoJRvn72C925+IyLT1gV2nJvsu2k1SQxfHD4fKeCCdSK8pqzH2Oi2S7NC4M6P2vtRq27BVEAwuQlnFbYq4DfNqqZaIpOVkjqvMQkLy3TvqVvMQ0B9dexBL3+MlOGSlplLjPrtLIeSZfOJEJtREFXMUpKUy5TDC6405YmIAGBivRHmTRKp7Vy9r/VfcJGy23U0eGsl76e3MYoLShT78Rb9tWof5TWATlAMt//MBMpQxMRS8RbWWdg1xqXePJUyq8jGjAMRqNHw5xITp73hH3C4Mrl61MCDViJ3ZAdpLTY4lFHbSMj84chPtWy0etWCIKepVo54pMYdTBFpec49d24JoMSCiQEW8EN3nohfr2IpyDMW8vISeXlhATpTyJSMgdv/K/8Zv2ARQiXspr2JGVDlW4JyJ/ro0lrh9CVy9sqg+WwJAk3rG52Q/QdZuS9cqDK37qTKjcYD7M7wV6vraAJ36eJhMJ0mq0n56RMpTj3r265BMWEMUpqCtURDYYLQUSLrm/Y+obiSc7KpyyocC1mmP/qZtYJOR3Swt6GHlZq4KGTfikHijG3ULW3p6mu1j+bevrvmGlFqGajSUSJ9Js2pDa7iqLnNlAamCCaxrPgo+Q== kamil.alekber@gmail.com"
  }
}

