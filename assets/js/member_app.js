import { phxApp_ } from './phx_app.js';
import { commerceApp_ } from './commerce_app.js';
export let memberApp_ = {
  user: {},
  ranks: [],
  restoreUser() {
    this.ranks = phxApp_.api("get_ranks", {})
    this.user = JSON.parse(localStorage.getItem("user"));
    if (this.user != null) {
      $("[aria-label='login']").addClass("d-none")
      $("[aria-label='logout']").removeClass("d-none")
    }
    if ($("form#register")) {
      if (this.user != null) {
        $("input[name='user[sales_person_id]']").val(this.user.id)
        $("input[name='user[sponsor]']").val(this.user.username)
        $("input[name='user[username]']").val("")
      }
    }
  },
  save(j) {
    localStorage.setItem("user", JSON.stringify(j))
  },
  redeem(dom) {
    $(dom).closest("form")

    if (phxApp_.chosen_country_id_ != null) {
      $("input[name='user[country_id]']").val(phxApp_.chosen_country_id_.id)
    }
    phxApp_.validateForm("form", () => {
      console.info("validating form...")
      phxApp_.form($(dom).closest("form"), "redeem", (e) => {
        console.info("after redeem form...")
        console.log(e)
        if (e != null) {

          console.log("e user")
          console.log(e.user)

          commerceApp_.emptyCart_()

          phxApp_.navigateTo(e.payment_url)
        } else {
          commerceApp_.emptyCart_()
          phxApp_.navigateTo("/profile")
        }
      })
    })
  },
  upgrade(dom) {
    $(dom).closest("form")
    if ($("form#register")) {
      if (this.user != null) {
        $("input[name='user[sales_person_id]']").val(this.user.id)

      }

      if (phxApp_.chosen_country_id_ != null) {
        $("input[name='user[country_id]']").val(phxApp_.chosen_country_id_.id)
      }
    }
    phxApp_.validateForm("form", () => {
      console.info("validating form...")
      phxApp_.form($(dom).closest("form"), "upgrade", (e) => {
        console.info("after upgrade form...")
        console.log(e)
        if (e != null) {
          if (e.billplz_code != null) {

            commerceApp_.emptyCart_()
            window.location = e.payment_url
          } else {
            // console.log("e user")
            // console.log(e.user)
            // memberApp_.updateUser(e.user)
            phxApp_.notify("Please relogin to update rank.")
            commerceApp_.emptyCart_()
            commerceApp_.components["userProfile"]()
            phxApp_.navigateTo(e.payment_url)
          }
        } else {
          commerceApp_.emptyCart_()
          phxApp_.navigateTo("/profile")
        }
      })
    })
  },
  register(dom) {
    if ($("form#register")) {
      if (this.user != null) {
        $("input[name='user[sales_person_id]']").val(this.user.id)

      }
      if (phxApp_.chosen_country_id_ != null) {
        console.log(phxApp_.chosen_country_id_)
        $("input[name='user[country_id]']").val(phxApp_.chosen_country_id_.id)
      }
    }

    phxApp_.validateForm("form", () => {
      console.log("validating form...")
      phxApp_.form($(dom).closest("form"), "register", (e) => {
        console.log("after register form...")
        console.log(e)
        if (e != null) {
          commerceApp_.emptyCart_()
          if (e.billplz_code != null) {

            window.location = e.payment_url
          } else {

            phxApp_.navigateTo(e.payment_url)
          }

        } else {
          commerceApp_.emptyCart_()
          phxApp_.navigateTo("/register")
        }
      })
    })
  },
  logout() {
    console.log("logging out...")
    localStorage.removeItem("user")
    $("[aria-label='login']").removeClass("d-none")
    $("[aria-label='logout']").addClass("d-none")
    phxApp_.notify("Log out!")
    document.cookie = "_commerce_front_key=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
    setTimeout(() => {
      location = "/login"
    }, 1000)
  },
  updateUser(user) {
    memberApp_.user = user
    memberApp_.save(user)
  },
  login(dom) {
    $(dom).closest("form")
    phxApp_.form($(dom).closest("form"), "login", (j) => {
      memberApp_.user = j
      memberApp_.save(j)
      $("[aria-label='login']").addClass("d-none")
      $("[aria-label='logout']").removeClass("d-none")
      phxApp_.navigateTo("/home")
    })
  }
}