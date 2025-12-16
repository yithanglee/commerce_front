import {
    ColumnFormater
} from './column_formatter.js';

import {
    memberApp_
} from './member_app.js';
import {
    phxApp_
} from './phx_app.js';

import {
    phoenixModel
} from './phoenixModel.js';
export let commerceApp_ = {
    cart_: [],
    mcart_: [],
    region: "MY",
    selectedInstalment: null,


    emptyCart_(is_merchant) {
        const cartKey = is_merchant ? "mcart" : "cart";
        const firstCartCountryIdKey = is_merchant ? "first_mcart_country_id" : "first_cart_country_id";

        if (is_merchant) {
            this.mcart_ = [];
        } else {
            this.cart_ = [];
        }

        localStorage.setItem(cartKey, JSON.stringify([]));
        localStorage.removeItem(firstCartCountryIdKey);
        commerceApp_[firstCartCountryIdKey] = null;
    },
    restoreCart(is_merchant) {
        const cartKey = is_merchant ? "mcart" : "cart";
        const firstCartCountryIdKey = is_merchant ? "first_mcart_country_id" : "first_cart_country_id";
        const cartData = localStorage.getItem(cartKey);

        if (cartData != null) {
            if (is_merchant) {
                this.mcart_ = JSON.parse(cartData);
                commerceApp_.first_mcart_country_id = localStorage.getItem(firstCartCountryIdKey);
            } else {
                this.cart_ = JSON.parse(cartData);
                commerceApp_.first_cart_country_id = localStorage.getItem(firstCartCountryIdKey);
            }
        }
    },
    filterItemsByName(itemName) {

        const cart = this.cart_;
        // const index = cart.findIndex(cartItem => cartItem.id === item.id);
        var res = cart.filter((v, i) => {
            return v.name.includes(itemName)
        })
        console.log(res)

        return res;
    },
    hasCartItems(is_merchant) {
        const cart = is_merchant ? this.mcart_ : this.cart_;
        return cart.length;
    },

    addItem_(item, is_merchant) {
        console.info(item)
        const cart = is_merchant ? this.mcart_ : this.cart_;
        const index = cart.findIndex(cartItem => cartItem.id === item.id);

        if (item.is_instalment) {
            if (item.payInstalment) {

            } else {

                instalment_name = item.name
                product_instalment_id = item.id
                item = item.first_payment_product
                item.selectedInstalmentId = product_instalment_id
                item.selectedInstalment = {
                    id: product_instalment_id,
                    name: instalment_name
                }
            }
        }


        if (index >= 0) {
            cart[index].qty += 1;
        } else {
            item.qty = 1;
            cart.unshift(item);
        }

        const cartKey = is_merchant ? "mcart" : "cart";
        localStorage.setItem(cartKey, JSON.stringify(cart));
    },
    addItemById_(id, is_merchant) {
        const cartKey = is_merchant ? "mcart" : "cart";
        const cart = is_merchant ? this.mcart_ : this.cart_;
        const index = cart.findIndex(cartItem => cartItem.id == parseInt(id));

        if (index >= 0) {

            var foundItem = cart[index]
            phxApp_.notify("item " + foundItem.name + " added !", {
                delay: 2000,
                type: "success",
                placement: {
                    from: "top",
                    align: "center"
                }
            })
            foundItem.qty += 1


        } else {
            // item.qty = 1
            // this.cart_ = [item, ...this.cart_]

        }



        localStorage.setItem(cartKey, JSON.stringify(cart))

    },
    minusItem_(id, is_merchant) {


        const cartKey = is_merchant ? "mcart" : "cart";
        const cart = is_merchant ? this.mcart_ : this.cart_;
        const index = cart.findIndex(cartItem => cartItem.id == parseInt(id));


        if (index >= 0) {

            var foundItem = cart[index]
            phxApp_.notify("item " + foundItem.name + " deducted !", {
                delay: 2000,
                type: "success",
                placement: {
                    from: "top",
                    align: "center"
                }
            })
            foundItem.qty -= 1

            if (foundItem.qty == 0) {

                this.removeItem_(id, is_merchant)
            }


        } else {
            // item.qty = 1
            // this.cart_ = [item, ...this.cart_]

        }

        localStorage.setItem(cartKey, JSON.stringify(cart))

    },
    removeItem_(id, is_merchant) {
        const cartKey = is_merchant ? "mcart" : "cart";
        const cart = is_merchant ? this.mcart_ : this.cart_;
        const index = cart.findIndex(cartItem => cartItem.id == parseInt(id));

        var foundItem = cart[index]

        phxApp_.notify("item " + foundItem.name + " removed !", {
            delay: 2000,
            type: "warning",
            placement: {
                from: "top",
                align: "center"
            }
        })

        var removed = cart.splice(index, 1)

        localStorage.setItem(cartKey, JSON.stringify(cart))

        if (commerceApp_.cart_.length == 0) {
            commerceApp_.first_cart_country_id = null
        }

    },
    toastChanges() {
        if ($("input[name='user[share_code]']").length > 0) {

        } else {

            phxApp_.toast({
                content: `<div class=""><ul class="">` + $(".ac").html() + `</ul></div>`
            })
        }
    },
    total_(is_merchant) {
        const cart = is_merchant ? this.mcart_ : this.cart_;
        var amount = this.cart.map((v, i) => {
            return v.price
        }).reduce((a, b) => {
            return a + b
        })
        return amount
    },
    render() {
        // this find all all the related components on the page and transform them.
        // has to be done after rendering page, 
        // callback function to call this render
        var list = ["merchantProducts", "merchantproduct", "merchantProfile", "merchant", "recruit", "topup", "country",
            "light", "userProfile", "wallet", "announcement", "products", "product",
            "rewardList", "rewardSummary","mcart", "cart", "cartItems", "salesItems", "upgradeTarget", "upgradeTargetMerchant", "sponsorTarget", "stockistTarget", "choosePayment"
        ]

        list.forEach((v, i) => {

            if ($(v).length > 0) {
                try {
                    this.components[v]()
                } catch (e) {
                    console.log(error)
                }
            }
        })
    },
    components: {
        merchantproduct() {
            $("merchantproduct").customHtml(`
          <div class="text-center mt-4">
            <div class="spinner-border loading2" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
          </div>
            
        <div class="loading2 d-none" id="mpcontent" />
        `)

            phxApp_.api("get_mproduct", {
                id: pageParams.id
            }, null, (data) => {
                $("title").html(data.name)

                function addToMCart() {

                    // check current cart if they have other merchant' items


                    var check = commerceApp_.mcart_.filter((v, i) => {
                        return v.merchant_id == data.merchant_id
                    })


                    if (check.length > 0) {
                        commerceApp_.addItem_(data, true)
                        commerceApp_.components["updateMCart"]()

                        phxApp_.notify("Added " + data.name, {
                            delay: 2000,
                            type: "success",
                            placement: {
                                from: "top",
                                align: "center"
                            }
                        })

                    } else {
                        if (commerceApp_.mcart_.length == 0) {
                            commerceApp_.addItem_(data, true)
                            commerceApp_.components["updateMCart"]()

                            phxApp_.notify("Added " + data.name, {
                                delay: 2000,
                                type: "success",
                                placement: {
                                    from: "top",
                                    align: "center"
                                }
                            })
                        } else {

                            alert("cant add due to different merchants, empty it first.")
                        }
                    }


                }

                $(".spinner-border.loading2").parent().remove()
                $(".loading2").removeClass("d-none")


                var img
                if (data.img_url != null) {

                    try {
                        img = data.img_url
                    } catch (e) {
                        img = '/images/placeholder.png'
                    }
                }
                $("#mpcontent").customHtml(`

        <div class="d-flex flex-column justify-content-center align-items-center ">
          <h2 id="ptitle">
          </h2>
              <div  class="d-flex justify-content-center p-4 " 
                  style="
                    position: relative; 
                    width: 320px;
                    height: 340px;">
              <div class="rounded py-2" style="
                    height: 340px;
                    width: 88%;
                    filter: blur(4px);
                    position: absolute;
                    background-repeat: no-repeat;
                    background-position: center;
                    background-size: cover;
                    background-image: url('` + img + `');
                    top: 30px;
                    left: 20px;
                    ">
              </div>
              <div class="rounded py-2" style="
                    height: 340px;
                    width:  100%;
                    z-index: 1;
                    background-position: center;
                    background-repeat: no-repeat;
                    background-size: cover; 
                    background-image: url('` + img + `');
                    ">
              </div>
            </div>
          <div style="margin-top: 50px;">` + data.description + `</div>
          <div class="font-sm fw-light text-secondary text-center "><span class="format-float">` + data.retail_price + ` </span> RP</div>
          <div class="btn btn-outline-primary mt-4" mproduct-id="` + data.id + `">Add</div>
        </div>

        `)
                $("#ptitle").html(
                    data.name
                )
                $("[mproduct-id='" + data.id + "']")[0].onclick = addToMCart

            })


        },
        merchantProducts() {

            let selectedCountry;


            function evalCt() {

                if (phxApp.user == null) {

                    return "b.is_approved=true|b.country_id=" + phxApp_.chosen_country_id_.id
                } else {
                    return "b.is_approved=true|b.country_id=" + phxApp.user.country_id
                }

            }

            function evalCard(onclickAttr, img, merchant, data, showBtn) {
                var card = `
                      <div  class="position-relative m-2 d-flex flex-column gap-2" ` + onclickAttr + `>
                        <div  class="d-flex justify-content-center mb-4 py-4 background-p" 
                              style="
                                cursor: pointer;   
                                position: relative; "
                               >
                          <div class="rounded py-2 background-p" style="
                            
                                width: 80%;
                                filter: blur(4px);
                                position: absolute;
                                background-repeat: no-repeat;
                                background-position: center;
                                background-size: cover;
                                background-image: url('` + img + `');
                                
                                ">
                          </div>
                          <div class="rounded py-2 foreground-p" style="
                               
                                width:  100%;
                                z-index: 1;
                                background-position: center;
                                background-repeat: no-repeat;
                                background-size: cover; 
                                background-image: url('` + img + `');
                                ">
                          </div>
                        </div>
                        <div class="d-flex position-absolute" style="left: 10px; top: 12px;z-index: 10;">
                          <div class="bg-primary badge">` + merchant.name + `</div>
                        </div>
                        <div class="d-flex flex-column justify-content-center gap-2 mt-4">
                          <div class="font-sm fw-bold text-center">` + data.name + `</div>
                           <div class="d-flex flex-column justify-content-center ">
                              <div class="font-sm fw-light text-secondary text-center "><span class="format-float">` + data.retail_price + `</span> RP</div>
                           </div>
                           ` + showBtn + `
                        </div>
                      </div>
                      `
                return card
            }


            function evalCountry(countryName) {
                var prefix = "v2"

                if (countryName == "Thailand") {
                    prefix = "th"
                }
                if (countryName == "Vietnam") {
                    prefix = "vn"
                }
                if (countryName == "China") {
                    prefix = "cn"
                }

                return prefix;
            }

            var countries = []


            phxApp_.countries_.forEach((v, i) => {
                countries.push(`
                  <button type="button" aria-name="` + v.name + `" aria-country="` + v.id + `" class="btn btn-primary ">` + v.name + ` ` + (v.alias || "") + `</button>
                `)
            })


            if (phxApp_.chosen_country_id_ == null && pageParams.share_code == null) {

                phxApp_.modal({
                    selector: "#mySubModal",
                    content: `
                      <center>
                        <div class="btn-group-vertical">
                        ` + countries.join("") + `
                        </div>
                      </center>
                    `,
                    header: "Choose region",
                    autoClose: false
                })

                $("[aria-country]").unbind()
                $("[aria-country]").click(function() {
                    var country_id = $(this).attr("aria-country"),
                        name = $(this).attr("aria-name")
                    phxApp_.chosen_country_id_ = country_id
                    phxApp_.notify("Chosen region: " + name)
                    localStorage.setItem("region", name)
                    setTimeout(() => {

                        $("#chosen-region").html(name)
                    }, 1000)
                    if (localStorage.region != null) {
                        langPrefix = evalCountry(name)
                    }
                    translationRes = phxApp_.api("translation", {
                        lang: langPrefix
                    });


                    $("#mySubModal").modal('hide')
                    commerceApp_.components["country"]()


                    // if (pageParams.share_code != null) {

                    //     phxApp_.api("get_share_link_by_code", {
                    //         code: pageParams.share_code
                    //     }, null, (sponsor) => {

                    //         commerceApp_.components["cartItems"]()

                    //         phxApp_.navigateTo(location.pathname)
                    //         $(".sponsor-name").customHtml("_sponsor: " + sponsor["user"]["username"] + " _position: " + sponsor.position)

                    //         $(".sponsor-bank").html(`

                    //           <div class="d-flex justify-content-between align-items-center">
                    //             <span class="fw-bold">Bank Details</span>
                    //             <span class=" my-4 me-4 d-flex justify-content-end align-items-end gap-1 flex-column">
                    //               <div>` + sponsor["user"]["bank_name"] + `</div>
                    //               <div>` + sponsor["user"]["bank_account_holder"] + `</div>
                    //               <div>` + sponsor["user"]["bank_account_no"] + `</div>
                    //             </span>
                    //           </div>

                    //             `)

                    //     })
                    // } else {

                    phxApp_.navigateTo("/home")
                        // }
                })

            }

            if (pageParams.share_code != null) {


                phxApp_.api("get_share_link_by_code", {
                    code: pageParams.share_code
                }, null, (sponsor) => {

                    selectedCountry = phxApp_.countries_.filter((v, i) => {
                        return v.id == sponsor["user"]["country_id"]
                    })[0]

                    console.info(selectedCountry)

                    phxApp_.chosen_country_id_ = sponsor["user"]["country_id"]
                    var country_id = sponsor["user"]["country_id"],
                        name = selectedCountry.name

                    phxApp_.notify("Chosen region: " + selectedCountry.name)
                    localStorage.setItem("region", selectedCountry.name)
                    setTimeout(() => {

                        $("#chosen-region").html(name)
                    }, 1000)
                    if (localStorage.region != null) {
                        langPrefix = evalCountry(name)
                    }
                    translationRes = phxApp_.api("translation", {
                        lang: langPrefix
                    });

                    commerceApp_.components["country"]()

                    // commerceApp_.components["cartItems"]()
                    // phxApp_.navigateTo(location.pathname)
                    $(".sponsor-name").customHtml("_sponsor: " + sponsor["user"]["username"] + " _position: " + sponsor.position)

                    $(".sponsor-bank").html(`

                              <div class="d-flex justify-content-between align-items-center">
                                <span class="fw-bold">Bank Details</span>
                                <span class=" my-4 me-4 d-flex justify-content-end align-items-end gap-1 flex-column">
                                  <div>` + sponsor["user"]["bank_name"] + `</div>
                                  <div>` + sponsor["user"]["bank_account_holder"] + `</div>
                                  <div>` + sponsor["user"]["bank_account_no"] + `</div>
                                </span>
                              </div>

                                `)


                })

            }




            if (phxApp_.chosen_country_id_ != null) {
                function addToMCart(dom) {
                    var id = $(dom).attr("mproduct-id")
                    var zdata = phxApp_.api("get_mproduct", {
                        id: id
                    }, () => {}, (data) => {
                        var check = commerceApp_.mcart_.filter((v, i) => {
                            return v.merchant_id == data.merchant_id
                        })

                        if (check.length > 0) {

                            try {

                                commerceApp_.addItem_(data, true)
                                commerceApp_.components["updateMCart"]()
                                commerceApp_.components["cartItems"]()

                                phxApp_.notify("Added " + data.name, {
                                    delay: 2000,
                                    type: "success",
                                    placement: {
                                        from: "top",
                                        align: "center"
                                    }
                                })

                            } catch (E) {
                                console.error(E)
                            }

                        } else {

                            if (commerceApp_.mcart_.length == 0) {
                                commerceApp_.addItem_(data, true)
                                commerceApp_.components["updateMCart"]()
                                commerceApp_.components["cartItems"]()

                                phxApp_.notify("Added " + data.name, {
                                    delay: 2000,
                                    type: "success",
                                    placement: {
                                        from: "top",
                                        align: "center"
                                    }
                                })
                            } else {

                                alert("cant add due to different merchants, empty it first.")
                            }

                        }

                    })

                }

                $("merchantProducts").each((i, products) => {
                    $(products).customHtml(`
                    <div class="text-center mt-4">
                      <div class="spinner-border loading" role="status">
                        <span class="visually-hidden">Loading...</span>
                      </div>
                    </div>
                      

                    <div class="row gx-0 d-none loading">
                      <div class="col-12 col-lg-10 offset-lg-1">
                        <div id="mproduct_tab1"></div>
                      </div>
                    </div>
                  `).then(() => {

                        var customCols = null,
                            random_id = 'mproducts',
                            productSource = new phoenixModel({
                                onDrawFn: () => {
                                    $(".spinner-border.loading").parent().remove()
                                    $(".loading").removeClass("d-none")


                                    setTimeout(() => {
                                        $("[mproduct-id]").each((i, v) => {
                                            v.onclick = () => {
                                                addToMCart(v)
                                            }
                                        })
                                        ColumnFormater.formatDate()
                                    }, 1200)

                                },
                                xcard: (params) => {

                                    var data = params,
                                        showBtn = '',
                                        img = '/images/placeholder.png',
                                        onclickAttr = `onclick="phxApp.navigateTo('/merchant_products/` + data.id + `/` + data.name + `')"`;


                                    if ($(products).attr("direct") != null) {
                                        onclickAttr = ''
                                        showBtn = `<div class="btn btn-outline-primary mt-4" mproduct-id="` + data.id + `">Add</div>`
                                    }
                                    if (data.img_url != null) {

                                        try {
                                            img = data.img_url
                                        } catch (e) {
                                            img = '/images/placeholder.png'
                                        }
                                    }

                                    var merchant = data.merchant

                                    return evalCard(onclickAttr, img, merchant, data, showBtn)


                                },
                                data: {
                                    sorts: [
                                        [1, "asc"]
                                    ],

                                    additional_join_statements: [{
                                        merchant: "merchant"

                                    }],
                                    additional_search_queries: [
                                        evalCt()

                                    ],

                                    preloads: ["merchant"],
                                    grid_class: "col-4 col-lg-3",
                                    dom: `

                                                      <"row px-4"
                                                        <"col-lg-6 col-12"i>
                                                        <"col-12 col-lg-6">
                                                      >
                                                      <"row grid_view ">
                                                      <"list_view d-none"t>
                                                      <"row transform-75 px-4"
                                                        <"col-lg-6 col-12">
                                                        <"col-lg-6 col-12"p>
                                                      >

                                                  `
                                },
                                columns: [

                                    {
                                        label: 'id',
                                        data: 'id'
                                    },
                                    // {
                                    //   label: 'retail_price',
                                    //   data: 'retail_price'
                                    // },

                                    {
                                        label: 'Action',
                                        data: 'id'
                                    }

                                ],
                                moduleName: "MerchantProduct",
                                link: "MerchantProduct",
                                customCols: customCols,
                                buttons: [],
                                tableSelector: "#" + random_id
                            })
                        productSource.load(random_id, "#mproduct_tab1")

                    })


                })

            }




        },

        merchantProfile() {
            $("merchantProfile").html(`
        <form class="with_mod row" module="Merchant" id="Merchant">
        </form>
        `)

            var merc = phxApp_.user.merchant

            if (phxApp_.user.merchant == null) {
                merc = {
                    id: "0",
                    user_id: phxApp.user.id
                }
            }
            var merchant_categorySourcex = new phoenixModel({
                columns: [{
                    label: 'Action',
                    data: 'id'
                }],
                moduleName: "MerchantCategory",
                link: "MerchantCategory",
                buttons: [],
                tableSelector: "#" + 'bc2c'
            })
            var bcs = phxApp_.populateTableData(merchant_categorySourcex, 100, () => {

            })

            try {

                console.info(bcs.allData)
            } catch (e) {

                console.error(e)

            }

            phxApp.createForm(merc,
                null, [{
                        name: 'General',
                        list: [

                            'id',
                            'user_id',
                            'name', {
                                label: 'merchant_category_id',
                                alt_name: 'Business Category',
                                alt_class: "col-12",
                                selection: merchant_categorySourcex.allData
                            }, {
                                alt_name: 'Merchant Logo',
                                label: 'img_url',
                                upload: true
                            }, {
                                label: 'description',
                                binary: true,
                                alt_class: "col-12"
                            },

                            {
                                label: 'commission_perc',
                                alt_name: 'Percentage Contribution',
                                selection: [{
                                    id: 0.05,
                                    name: "5%"
                                }, {
                                    id: 0.1,
                                    name: "10%"
                                }, {
                                    id: 0.15,
                                    name: "15%"
                                }, {
                                    id: 0.2,
                                    name: "20%"
                                }, {
                                    id: 0.22,
                                    name: "25%"
                                }, {
                                    id: 0.3,
                                    name: "30%"
                                }, {
                                    id: 0.35,
                                    name: "35%"
                                }, {
                                    id: 0.4,
                                    name: "40%"
                                }, {
                                    id: 0.45,
                                    name: "45%"
                                }, {
                                    id: 0.5,
                                    name: "50%"
                                }]
                            },

                        ]
                    }, {
                        name: 'CompanyDetails',
                        list: [

                            {
                                label: 'company_address',
                                alt_name: "Address",
                                alt_class: "col-12",
                                binary: true
                            }, {
                                label: 'company_email',
                                alt_name: "Email",
                                alt_class: "col-12"
                            }, {
                                label: 'company_phone',
                                alt_name: "Phone",
                                alt_class: "col-12"
                            },



                            {
                                label: 'company_reg_no',
                                alt_name: "Reg No",
                                alt_class: "col-12"
                            }, {
                                label: 'company_ssm_image_url',
                                alt_name: "SSM Image",
                                alt_class: "col-12",
                                upload: true
                            },


                        ]
                    }, {
                        name: 'BankDetails',
                        list: [

                            {
                                label: 'bank_name',
                                alt_name: "Bank Name",
                                alt_class: "col-12"
                            }, {
                                label: 'bank_account_holder',
                                alt_name: "Bank Account Holder",
                                alt_class: "col-12"
                            }, {
                                label: 'bank_account_no',
                                alt_name: "Account Number",
                                alt_class: "col-12"
                            },

                        ]
                    }


                ],

                (j) => {
                    console.info(j)
                        // phxApp_.user.merchant = j
                    memberApp_.extendUser()
                    phxApp.navigateTo("/merchant_profile")
                }

            )
        },

        merchant() {
            var cta = ` <div class="btn btn-primary btn-lg merchant-apply mb-4 disabled">Apply</div>`

            if (phxApp_.user.merchant != null) {
                if (phxApp_.user.merchant.is_approved == false) {
                    cta = ` <div class="btn btn-primary btn-lg merchant-apply ">Pending Approval</div>`

                } else {
                    phxApp_.navigateTo("/merchant_profile")
                }

            }

            function agree() {
                console.log("agree")

                $(".merchant-apply ").toggleClass("disabled")
            }

            window.agree = agree


            $("merchant").html(`
          <h2 class="mt-2">Merchant Application</h2> 
          <div class="px-4 m-4">
            Terms and condition
          </div>
          <center class="w-100 d-lg-none d-block">
            <iframe class="my-4" style="width:100%; height: 600px;"  src="https://docs.google.com/document/d/e/2PACX-1vShkzZ2LaszYkpcKw82giaYPqzRhB8odK54rkrJLwc6YMiUNp7HLaHYFTYN0hNPngJvJ_XR36_T8b5Z/pub?embedded=true"></iframe>
          </center>
          
          <center class="w-100 d-lg-block d-none">
            <iframe class="my-4" style="width: 60%; height: 600px;"  src="https://docs.google.com/document/d/e/2PACX-1vShkzZ2LaszYkpcKw82giaYPqzRhB8odK54rkrJLwc6YMiUNp7HLaHYFTYN0hNPngJvJ_XR36_T8b5Z/pub?embedded=true"></iframe>
          </center>
          <center>

          <div class="form-check m-4">
            <input class="form-check-input" onchange="agree()" type="checkbox" value="" id="flexCheckDefault">
            <label class="form-check-label" for="flexCheckDefault">
            I agree to above terms and condition
            </label>
          </div>

          </center>
          <div>
           ` + cta + `
          </div>

        `)


            $(".merchant-apply").on("click", () => {


                phxApp_.post("apply_merchant", {
                    id: phxApp_.user.id
                }, null, () => {

                    phxApp_.navigateTo("/merchant_profile")

                })


            })
        },
        recruit() {

            $("recruit").each((i, recruit) => {
                console.log(recruit)

                var v = $(recruit).attr("merchant")
                console.log(v == "")
                if (v == "") {
                    $(recruit).customHtml(`

            <div class="">
                <label class="my-2">Position</label>
                <select class="form-control" name="mposition">
                  <option>left</option>
                  <option>right</option>
                </select>
                <div class="mt-4 btn btn-primary generate-mlink">Generate</div>
            </div>



            `)
                } else {

                    $(recruit).customHtml(`

            <div class="">
                <label class="my-2">Position</label>
                <select class="form-control" name="position">
                  <option>left</option>
                  <option>right</option>
                </select>
                <div class="mt-4 btn btn-primary generate-link">Generate</div>
            </div>



            `)
                }

                $(".generate-mlink").click(() => {

                    phxApp_.api("get_merchant_share_link", {
                        username: phxApp_.user.username,
                        position: $("select[name='mposition']").val()
                    }, null, (code) => {




                        phxApp_.modal({
                            autoClose: false,
                            header: 'Share Link',
                            selector: "#mySubModal",
                            content: `

                  <label class="my-2">Generated</label>
                  <input class="form-control" name="link"></input>
                  <div class="mt-4 btn btn-primary copy-link">Copy</div>




                `
                        })

                        $("input[name='link']").val(code.link)
                        $(".copy-link").click(() => {
                            try {
                                navigator.clipboard.writeText(code.link);
                                console.log('Content copied to clipboard');
                                phxApp_.notify("Copied!")

                            } catch (E) {
                                phxApp_.notify("Cant copy", {
                                    type: "danger"
                                })
                            }
                        })

                    })

                })
                $(".generate-link").click(() => {

                    phxApp_.api("get_share_link", {
                        username: phxApp_.user.username,
                        position: $("select[name='position']").val()
                    }, null, (code) => {




                        phxApp_.modal({
                            autoClose: false,
                            header: 'Share Link',
                            selector: "#mySubModal",
                            content: `

                  <label class="my-2">Generated</label>
                  <input class="form-control" name="link"></input>
                  <div class="mt-4 btn btn-primary copy-link">Copy</div>




                `
                        })

                        $("input[name='link']").val(code.link)
                        $(".copy-link").click(() => {
                            try {
                                navigator.clipboard.writeText(code.link);
                                console.log('Content copied to clipboard');
                                phxApp_.notify("Copied!")

                            } catch (E) {
                                phxApp_.notify("Cant copy", {
                                    type: "danger"
                                })
                            }
                        })

                    })

                })
            })

        },
        choosePayment() {



            var razerList = phxApp.api("razer_list", {}),
                channels =
                Object.keys(razerList),
                sections = [];



            channels.forEach((channel, i) => {
                var subSections = []

                razerList[channel].forEach((child, ii) => {

                    var div = `

            <div class="py-1 col-6 col-lg-4 use-channel" aria-channel-label='` + child.channel_map.direct.request + `' >
              <img class="w-100 m-2 m-lg-0" src="` + child.logo_url_120x43 + `"></img>
            </div>
            `
                    if (child.currency.includes("MYR")) {

                        if (child.status == 1) {

                            if (child.channel_map.direct.request != "") {

                                subSections.push(div)
                            }
                        }
                    }
                })


                sections.push(`

            <div class="row mt-2 pb-1 border-success border-bottom">
           
            ` + subSections.join("") + `
            </div>


            `)

            })

            $("choosePayment").html(`
          <div class="my-4 d-flex justify-content-between">
            <div  class="btn btn-primary" onclick="$('#myPaymentModal').modal('show')">
              Choose Payment
            </div>
            <div class="" id="chosen-payment">
            </div>
          </div>
          <div class="modal" id="myPaymentModal">
            <div class="modal-dialog modal-lg" role="document">
              <div class="modal-content">
                <div class="modal-header">
                  <h5 class="modal-title">Choose Payment</h5>
                  <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true"></span>
                  </button>
                </div>
                <div class="modal-body">
               

                        <section class="ps-0 p-4 razer-display">
                          <h4>Pay with</h4>
                        ` + sections.join("") + `
                        </section>
               
                </div>
                <div class="modal-footer">
                </div>
              </div>
            </div>
          </div>
        `)




            $(".use-channel").click(function() {
                var channel = $(this).attr("aria-channel-label")
                $(".use-channel").removeClass("border border-primary rounded")
                $(this).addClass("border border-primary rounded")
                console.info("use channel: " + channel)
                $("input[name='user[payment][channel]']").val(channel)


                var p = $(this).html()
                $("#chosen-payment").html(p)
                $('#myPaymentModal').modal('hide')
            })



        },
        topup() {
            function payData(params) {
                var rowData = phxApp.rowData(params)
                console.log(rowData)
                if (rowData.payment != null) {
                    if (rowData.payment.payment_method == "fpx") {


                        msg = ''

                        if (rowData.is_approved == false) {
                            msg = `<p>You will be redirected to pay this topup.</p>
              <a target="_blank" href="` + rowData.payment.payment_url + `" class="btn btn-primary">Pay
              </a>`
                        }


                        phxApp.modal({
                            autoClose: false,
                            selector: "#mySubModal",
                            header: "FPX",
                            content: `

              ` + msg + `
              <div class="btn btn-primary check">Recheck
              </div>

              `
                        })

                        $(".check").click(() => {
                            phxApp.api("check_bill", {
                                id: rowData.payment.billplz_code
                            })
                        })

                    } else {
                        phxApp.modal({
                            selector: "#mySubModal",
                            header: "Details",
                            content: `

            <div class="btn btn-primary delete">Delete Request
              </div>


              `
                        })
                    }

                } else {

                    phxApp.modal({
                        selector: "#mySubModal",
                        header: "Details",
                        content: `

              <p>` + rowData.remarks + `</p>

              `
                    })
                }



                $(".delete").unbind()
                $(".delete").click(() => {
                    phxApp.api("delete_topup_request", {
                        id: rowData.id
                    }, null, (r) => {

                        $("#mySubModal").modal('hide')
                        if (r.status == "error") {
                            if (r.reason != "") {
                                phxApp.notify("Not Deleted! Reason: " + r.reason, {
                                    type: "danger"
                                })
                            }
                        } else {
                            phxApp.notify("Deleted!")
                            phxApp.navigateTo("/topup_register_point")
                        }
                    })
                })

            }
            $("topup").customHtml(`    
        <div class="card-body ">
          <div class="d-flex justify-content-between align-items-center mb-4">
            <h3>Topup Transaction</h3>
            <div class="btn btn-primary " id="new_topup">
              <span class="d-flex align-items-center"><i class="fa fa-plus me-1"></i>Topup</span></div>
          </div>
          <div class="" id="tab2"></div>
        </div>
          `)

            window.selectedBank = (bank) => {
                var valu = $("input[name='WalletTopup[bank]']").val(bank)
            }


            var razerList = phxApp.api("razer_list", {}),
                channels =
                Object.keys(razerList),
                sections = [];



            channels.forEach((channel, i) => {
                var subSections = []

                razerList[channel].forEach((child, ii) => {

                    var div = `

            <div class="py-1 col-6 col-lg-4 use-channel" aria-channel-label='` + child.channel_map.direct.request + `' >
              <img class="w-100 m-2 m-lg-0" src="` + child.logo_url_120x43 + `"></img>
            </div>
            `
                    if (child.currency.includes("MYR")) {

                        if (child.status == 1) {

                            if (child.channel_map.direct.request != "") {

                                subSections.push(div)
                            }
                        }
                    }
                })


                sections.push(`

            <div class="row mt-2 pb-1 border-success border-bottom">
           
            ` + subSections.join("") + `
            </div>


            `)

            })


            $("#new_topup").click(() => {

                phxApp.modal({
                    selector: "#mySubModal",
                    autoClose: false,
                    header: 'New Register Point Topup',
                    content: `
            <div class="row ">
              <form class="col-12 offset-lg-1 col-lg-10 with_mod row p-4" module="WalletTopup" id="WalletTopup">
               

              </form>

            </div>
        `
                })



                phxApp.createForm({
                        id: "0",
                        user_id: phxApp.user.id
                    },
                    null, ['id', {
                            label: 'amount',
                            alt_name: 'Amount (RP)',
                            alt_class: "col-12"
                        }, {
                            label: 'remarks',
                            alt_name: 'Description',
                            alt_class: "col-12"
                        }, {
                            label: 'payment-placeholder',
                            alt_name: 'Choose Payment',
                            alt_class: "col-12",
                            placeholder: `


                <div id="payment-placeholder">
                  <section class="p-4 razer-display">
                    <h3>Choose 1 channel</h3>
                  ` + sections.join("") + `
                  </section>
                  <section class="d-none upload-display">
                    <div class="px-4 pt-4">
                      Kindly bank in to either 1 of these account.
                    </div>
                    <div class="p-4 fs-5">
                      HAHO LIFE SDN. BHD.<br>
                      <span>
                        <div> MBB </div>
                        <div>5642 4949 7131  <div class="btn btn-primary" onclick="phxApp.copyToClipboard('564249497131');selectedBank('MBB')">Copy</div></div>
                      </span><br>
                      <span>
                        <div> CIMB </div>
                        <div>8011 2277 45 <div class="btn btn-primary" onclick="phxApp.copyToClipboard('8011227745');selectedBank('CIMB')">Copy</div></div>
                      </span><br>
                      <span>
                        <div> PUBLIC BANK </div>
                        <div>3237 7779 07 <div class="btn btn-primary" onclick="phxApp.copyToClipboard('3237777907');selectedBank('PBB')">Copy</div></div>
                      </span><br>
                    </div>
                  </section>
                  <div class="btn-group" role="group" aria-label="PaymentGroup">
                    <input type="radio" class="btn-check show-upload" name="btnradio" id="btnradio1z" autocomplete="off" >
                    <label class="btn btn-outline-primary" for="btnradio1z">Upload Bank In Slip</label>

                    <input type="radio" class="btn-check show-razer" name="btnradio" id="btnradio2z" autocomplete="off" checked="">
                    <label class="btn btn-outline-primary" for="btnradio2z">Online Banking/CC</label>
         
                  </div>

                </div>

            `
                        },

                        {
                            label: 'payment_method',
                            selection: [{
                                id: 'fpx',
                                name: 'FPX'
                            }, {
                                id: 'bank in slip',
                                name: 'BANK IN SLIP'
                            }],
                            alt_class: "d-none"
                        }, {
                            label: 'img_url',
                            upload: true,
                            alt_class: "d-none upload-display"
                        }, {
                            label: 'bank',
                            data: 'bank',
                            hidden: true
                        },
                        'user_id'

                    ],

                    (j) => {
                        console.info(j)
                        if (j.payment_method == "fpx") {


                            function postRedirect(url, data) {
                                // Create a form element
                                var form = $('<form>', {
                                    'method': 'POST',
                                    'action': url
                                });

                                // Append input elements for each data key-value pair to the form
                                $.each(data, function(key, value) {
                                    $('<input>', {
                                        'type': 'hidden',
                                        'name': key,
                                        'value': value
                                    }).appendTo(form);
                                });

                                // Append the form to the body and submit it
                                form.appendTo('body').submit();
                            }


                            postRedirect(j.payment.payment_url, JSON.parse(j.payment.webhook_details));

                        } else {

                            phxApp.navigateTo("/topup_register_point")
                        }

                    }

                )


                $(".show-upload").click(() => {
                    $(".upload-display").removeClass("d-none")
                    $(".razer-display").addClass("d-none")
                    $("select[name='WalletTopup[payment_method]']").val('bank in slip')
                })
                $(".show-razer").click(() => {
                    $(".upload-display").addClass("d-none")
                    $(".razer-display").removeClass("d-none")
                    $("select[name='WalletTopup[payment_method]']").val('fpx')
                })


                $("input[name='WalletTopup[amount]']").on("change", () => {
                    var valu = $("input[name='WalletTopup[amount]']").val()
                    $("input[name='WalletTopup[remarks]']").val("MYR " + valu * 5)
                })

                $(".use-channel").click(function() {
                    var channel = $(this).attr("aria-channel-label")
                    $(".use-channel").removeClass("border border-primary rounded")
                    $(this).addClass("border border-primary rounded")
                    console.info("use channel: " + channel)
                    $("input[name='WalletTopup[bank]']").val(channel)
                })


            })

            var customCols = null;
            var random_id = phxApp.makeid(4)
            wallet_topupSource = new phoenixModel({
                onDrawFn: () => {
                    setTimeout(() => {
                        phxApp.formatDate()
                    }, 200)
                },
                xcard: (params) => {
                    console.log(params)
                    var data = params

                    var font_class = "text-success"
                    if (data.amount < 0) {
                        font_class = "text-danger"
                    }
                    var status = `<span class="badge bg-warning">PENDING</span>`
                    if (data.is_approved) {
                        status = `<span class="badge bg-success">APPROVED</span>`
                    }
                    var card = `
         

          <div class="row border-1 border-top py-2">
            <div class="col-6 text-start text-sm">` + status + `</div>
           <div class="col-6 text-end text-sm">Amount (RP)</div>
          </div>
          <div class="row">
            <div class="col-6 text-start text-sm format_datetime">` + data.inserted_at + `</div>
       
           <div class="col-6 text-end "> <span class='format-integer'>` + data.amount + `</span></div>
          </div>

          `
                    return card
                },
                data: {
                    grid_class: "col-12 ",
                    dom: `
         <"row px-4 px-lg-0" 
          <"col-12 col-lg-6 "l>
          <"col-12 col-lg-6 text-lg-end "i>
        >
        <"row grid_view d-block d-lg-none">
        <"list_view d-none d-lg-block"t>
        <"row transform-75 px-4"
            <"col-lg-6 col-12">
            <"col-lg-6 col-12"p>
          >
      `,
                    preloads: ["user", "payment"],
                    additional_join_statements: [{
                        user: "user"
                    }, ],
                    additional_search_queries: [
                        "a.user_id=" + phxApp.user.id
                    ],
                },
                columns: [

                    {
                        label: 'id',
                        data: 'id'
                    }, {
                        label: 'Date',
                        data: 'inserted_at',
                        formatDateTime: true,
                        offset: 0
                    },



                    {
                        customized: true,

                        label: 'Approved?',
                        data: 'is_approved',
                        xdata: {
                            formatFn: (d, index) => {
                                if (d.is_approved) {
                                    html = `<div  ><i class="fa fa-check text-success"></i><span  class="ms-2">Approved</span></div>`
                                } else {
                                    html = `<div  ><i class="fa fa-hourglass text-warning"></i><span class="ms-2">Pending</span></div>`

                                }
                                return html
                            }
                        }
                    },

                    {
                        label: "Payment",
                        data: "id",
                        showChild: true,
                        xdata: {
                            child: 'payment',
                            data: 'payment_method'
                        }
                    }, {
                        label: 'Amount',
                        data: 'amount',
                        className: "format-float"
                    }, {
                        label: 'Action',
                        data: 'id',
                        className: ""
                    }

                ],
                moduleName: "WalletTopup",
                link: "WalletTopup",
                customCols: customCols,
                buttons: [{
                    name: "Details",
                    iconName: "fa fa-info",
                    color: "btn-sm btn-outline-warning",
                    onClickFunction: payData,
                    fnParams: {

                    }
                }, ],
                tableSelector: "#" + random_id
            })
            wallet_topupSource.load(random_id, "#tab2")
        },
        country() {
            if (localStorage.getItem("region") != null) {


                var sel =
                    phxApp_.countries_.filter((v, i) => {
                        return v.name == localStorage.getItem("region")
                    })[0]


                phxApp_.chosen_country_id_ = sel

                $("country").customHtml(`


        <li class="nav-item">
          <a class="nav-link choose-region" href="javascript:void(0);" > <i class="fa fa-globe"></i>` + localStorage.getItem("region") + `</a>
        </li>

      `)

            } else {

                $("country").customHtml(`


        <li class="nav-item">
          <a class="nav-link choose-region" href="javascript:void(0);" > <i class="fa fa-globe"></i> MY</a>
        </li>

      `)

            }
            var countries = []


            phxApp_.countries_.forEach((v, i) => {
                countries.push(`
            <button type="button" aria-name="` + v.name + `" aria-country="` + v.id + `" class="btn btn-primary ">` + v.name + `</button>
          `)
            })
            $(".choose-region").click(() => {
                commerceApp_.emptyCart_()
                phxApp_.modal({
                    selector: "#mySubModal",
                    content: `
          <center>
            <div class="btn-group-vertical">
            ` + countries.join("") + `
            </div>
          </center>
        `,
                    header: "Choose region",
                    autoClose: false
                })
                $("[aria-country]").unbind()
                $("[aria-country]").click(function() {
                    var country_id = $(this).attr("aria-country"),
                        name = $(this).attr("aria-name")
                    phxApp_.chosen_country_id_ = country_id
                    phxApp_.notify("Chosen region: " + name)
                    localStorage.setItem("region", name)
                    setTimeout(() => {

                        $("#chosen-region").html(name)
                    }, 1000)
                    $("#mySubModal").modal('hide')

                    try {


                        var langPrefix = "v2";

                        function evalCountry(countryName) {
                            var prefix = "v2"

                            if (countryName == "Thailand") {
                                prefix = "th"
                            }
                            if (countryName == "Vietnam") {
                                prefix = "vn"
                            }
                            if (countryName == "China") {
                                prefix = "cn"
                            }

                            return prefix;
                        }

                        if (localStorage.region != null) {
                            langPrefix = evalCountry(localStorage.region)
                        }

                        translationRes = phxApp_.api("translation", {
                            lang: langPrefix
                        });
                    } catch (error) {
                        console.error("Error fetching translation:", error);
                    }

                    commerceApp_.components["country"]()
                    commerceApp_.components["products"]()
                    if ($("[name='user[pick_up_point_id]']").length > 0) {

                        commerceApp_.components["cartItems"]()
                    }



                })

            })

        },

        upgradeTarget() {
            var needInstalment = false,
                freebie = null,
                instalmentProduct;
            if ($("upgradeTarget").attr("instalment") != null) {
                console.log("ok")
                needInstalment = true
                commerceApp_.emptyCart_()
            }

            window.upgradeTarget
            if (window.upgradeTarget == null) {
                window.upgradeTarget = memberApp_.user.username
                $("input[name='user[upgrade]']").val(window.upgradeTarget)
            } else {
                $("input[name='user[upgrade]']").val(window.upgradeTarget)
            }
            $("upgradeTarget").customHtml(`<span>for: <span id="upgradeTarget">` + window.upgradeTarget + `</span> <a class="ms-4" href="javascript:void(0);" aria-upgrade=true> <i class="fa fa-edit"></i> Change</a> </span>`)

            $("[aria-upgrade]").click(() => {
                phxApp_.modal({
                    selector: "#mySubModal",
                    autoClose: false,
                    content: `
          <div>
            <div class="form-group">
              <label>Username</label>
              <input class="my-2 form-control" type="text" name='upgrade[username]'></input>
                <div class="form-text text-muted pv-info"></div>

              <button class="mt-4 btn btn-outline-primary checkUser">Check</button>
              <button class="mt-4 btn btn-primary disabled selectUser">Select this user</button>
            </div>
          </div>
          `,
                    header: 'Change Upgrade User',
                })
                $(".checkUser").click(() => {


                    phxApp_.api("get_accumulated_sales", {
                            show_instalment: true,
                            parent_id: memberApp_.user.id,
                            show_rank: true,
                            username: $("[name='upgrade[username]']").val(),

                        }, () => {
                            window.upgradeTarget = memberApp_.user.username
                            $("input[name='user[upgrade]']").val(window.upgradeTarget)
                            $(".selectUser").addClass("disabled")

                        },
                        (res) => {
                            phxApp_.notify("User verified!")
                            $(".selectUser").removeClass("disabled")
                            $(".pv-info").customHtml(`Accumulated sales PV: ` + res[0] + ` | Rank: ` + res[1])

                            if (res[2].is_direct_downline) {
                                $(".to-upgrade").removeClass("disabled")
                            } else {


                                phxApp_.notify("User not direct downline!", {
                                    type: 'warning'
                                })

                                $("label[for='btnradio3']").click()
                                $(".to-upgrade").addClass("disabled")
                                if (res[4].outstanding_instalments != null) {
                                    if (res[4].outstanding_instalments.product.can_pay_by_drp) {
                                        $(".to-upgrade").removeClass("disabled")
                                    }
                                } else {

                                }
                            }
                            // please stick DRP
                            console.info(res[4].outstanding_instalments)
                            try {
                                if (res[4].outstanding_instalments != null) {


                                    $("input[name='user[shipping][fullname]']").val(res[4].outstanding_instalments.user.fullname)
                                    $("input[name='user[shipping][phone]']").val(res[4].outstanding_instalments.user.phone)
                                    $("input[name='user[instalment]']").val('Month no: ' + res[4].outstanding_instalments.month_no + '/' + res[4].outstanding_instalments.instalment.no_of_months)
                                    instalmentProduct = res[4].outstanding_instalments.product
                                    freebie = res[4].outstanding_instalments.member_instalment_product.product
                                }
                            } catch (e) {
                                console.error(e)
                            }
                        })


                })
                $(".selectUser").click(() => {
                    $("input[name='user[upgrade]']").val($("[name='upgrade[username]']").val())
                    phxApp_.notify("User selected!")

                    $("#mySubModal").modal('hide')
                    window.upgradeTarget = $("[name='upgrade[username]']").val()
                    $("#upgradeTarget").html($("[name='upgrade[username]']").val())
                    if (instalmentProduct != null) {

                        phxApp_.addItem(instalmentProduct.id)
                        if (freebie != null) {

                            phxApp_.addItem(freebie.id)
                        }

                    }
                    commerceApp_.components["cartItems"]()
                    console.info("need to check if member is direct sponsor")




                })
            })

        },
        upgradeTargetMerchant() {
            var needInstalment = false,
                freebie = null,
                instalmentProduct;
            if ($("upgradeTarget").attr("instalment") != null) {
                console.log("ok")
                needInstalment = true
                commerceApp_.emptyCart_()
            }

            window.upgradeTarget
            if (window.upgradeTarget == null) {
                window.upgradeTarget = memberApp_.user.username
                $("input[name='user[upgrade]']").val(window.upgradeTarget)
            } else {
                $("input[name='user[upgrade]']").val(window.upgradeTarget)
            }
            $("upgradeTargetMerchant").customHtml(`<span>for: <span id="upgradeTarget">` + window.upgradeTarget + `</span> <a class="ms-4" href="javascript:void(0);" aria-upgrade=true> <i class="fa fa-edit"></i> Change</a> </span>`)

            $("[aria-upgrade]").click(() => {
                phxApp_.modal({
                    selector: "#mySubModal",
                    autoClose: false,
                    content: `
          <div>
            <div class="form-group">
              <label>Username</label>
              <input class="my-2 form-control" type="text" name='upgrade[username]'></input>
                <div class="form-text text-muted pv-info"></div>

              <button class="mt-4 btn btn-outline-primary checkUser">Check</button>
              <button class="mt-4 btn btn-primary disabled selectUser">Select this user</button>
            </div>
          </div>
          `,
                    header: 'Change Upgrade User',
                })
                $(".checkUser").click(() => {


                    phxApp_.api("get_accumulated_sales_merchant", {
                            show_instalment: true,
                            parent_id: memberApp_.user.id,
                            show_rank: true,
                            username: $("[name='upgrade[username]']").val(),

                        }, () => {
                            window.upgradeTarget = memberApp_.user.username
                            $("input[name='user[upgrade]']").val(window.upgradeTarget)
                            $(".selectUser").addClass("disabled")

                        },
                        (res) => {
                            phxApp_.notify("User verified!")
                            $(".selectUser").removeClass("disabled")
                            $(".pv-info").customHtml(`Accumulated sales PV: ` + res[0] + ` | Rank: ` + res[1])

                            if (res[2].is_direct_downline) {
                                $(".to-upgrade").removeClass("disabled")
                            } else {


                                phxApp_.notify("User not direct downline!", {
                                    type: 'warning'
                                })

                                $("label[for='btnradio3']").click()
                                $(".to-upgrade").addClass("disabled")
                                if (res[4].outstanding_instalments != null) {
                                    if (res[4].outstanding_instalments.product.can_pay_by_drp) {
                                        $(".to-upgrade").removeClass("disabled")
                                    }
                                } else {

                                }
                            }
                            // please stick DRP
                            console.info(res[4].outstanding_instalments)
                            try {
                                if (res[4].outstanding_instalments != null) {


                                    $("input[name='user[shipping][fullname]']").val(res[4].outstanding_instalments.user.fullname)
                                    $("input[name='user[shipping][phone]']").val(res[4].outstanding_instalments.user.phone)
                                    $("input[name='user[instalment]']").val('Month no: ' + res[4].outstanding_instalments.month_no + '/' + res[4].outstanding_instalments.instalment.no_of_months)
                                    instalmentProduct = res[4].outstanding_instalments.product
                                    freebie = res[4].outstanding_instalments.member_instalment_product.product
                                }
                            } catch (e) {
                                console.error(e)
                            }
                        })


                })
                $(".selectUser").click(() => {
                    $("input[name='user[upgrade]']").val($("[name='upgrade[username]']").val())
                    phxApp_.notify("User selected!")

                    $("#mySubModal").modal('hide')
                    window.upgradeTarget = $("[name='upgrade[username]']").val()
                    $("#upgradeTarget").html($("[name='upgrade[username]']").val())
                    if (instalmentProduct != null) {

                        phxApp_.addItem(instalmentProduct.id)
                        if (freebie != null) {

                            phxApp_.addItem(freebie.id)
                        }

                    }
                    commerceApp_.components["cartItems"]()
                    console.info("need to check if member is direct sponsor")




                })
            })

        },
        sponsorTarget() {

            window.sponsorTarget
            if (window.sponsorTarget == null) {
                window.sponsorTarget = memberApp_.user.username
            } else {}
            $("input[name='user[sponsor]']").val('')
            $("sponsorTarget").customHtml(`<span>for: <span id="sponsorTarget">` + window.sponsorTarget + `</span>
       <a class="ms-4" href="javascript:void(0);" aria-sponsor=true> <i class="fa fa-edit"></i> Change</a> </span>`)

            $("[aria-sponsor]").click(() => {
                phxApp_.modal({
                    selector: "#mySubModal",
                    autoClose: false,
                    content: `
          <div>
            <div class="form-group">
              <label>Username</label>
              <input class="my-2 form-control" value="` + memberApp_.user.username + `" type="text" name='sponsor[username]'></input>
              

              <button class="mt-4 btn btn-outline-primary checkUser">Check</button>
              <button class="mt-4 btn btn-primary disabled selectUser">Select this user</button>
            </div>
          </div>
          `,
                    header: 'Change Sponsor User',
                })
                $(".checkUser").click(() => {


                    phxApp_.api("get_accumulated_sales", {
                            parent_id: memberApp_.user.id,
                            show_rank: true,
                            username: $("[name='sponsor[username]']").val(),

                        }, () => {
                            window.sponsorTarget = memberApp_.user.username
                            $("input[name='user[sponsor]']").val(window.sponsorTarget)
                            $(".selectUser").addClass("disabled")

                        },
                        (res) => {

                            $(".selectUser").removeClass("disabled")
                            $(".pv-info").customHtml(`Accumulated sales PV: ` + res[0] + ` | Rank: ` + res[1])

                            if (res[2].is_direct_downline) {
                                $(".to-upgrade").removeClass("disabled")
                            } else {
                                $("label[for='btnradio3']").click()
                                $(".to-upgrade").addClass("disabled")
                            }


                            if (res[3].is_downline) {
                                phxApp_.notify("User verified!")
                                    // $(".to-upgrade").removeClass("disabled")
                            } else {
                                if ($("input[name='sponsor[username]']").val() == memberApp_.user.username) {
                                    phxApp_.notify("User verified!")
                                } else {
                                    phxApp_.notify("Not downline!", {
                                        type: "warning"
                                    })
                                    $(".selectUser").addClass("disabled")
                                }
                            }



                        })


                })
                $(".selectUser").click(() => {
                    $("input[name='user[sponsor]']").val($("[name='sponsor[username]']").val())
                    $("input[name='view[sponsor]']").val($("[name='sponsor[username]']").val())
                    phxApp_.notify("User selected!")

                    $("#mySubModal").modal('hide')
                    window.sponsorTarget = $("[name='sponsor[username]']").val()
                    $("#sponsorTarget").html($("[name='sponsor[username]']").val())

                    commerceApp_.components["cartItems"]()
                    console.info("need to check if member is direct sponsor")




                })
            })

        },
        stockistTarget() {

            window.stockistTarget
            if (window.stockistTarget == null) {
                window.stockistTarget = memberApp_.user.username
            } else {}
            $("input[name='user[stockist_user_id]']").val('')
            $("stockistTarget").customHtml(`<span>for: <span id="stockistTarget">` + window.stockistTarget + `</span>
       <a class="ms-4" href="javascript:void(0);" aria-stockist=true> <i class="fa fa-edit"></i> Change</a> </span>`)

            $("[aria-stockist]").click(() => {
                phxApp_.modal({
                    selector: "#mySubModal",
                    autoClose: false,
                    content: `
          <div>
            <div class="form-group">
              <label>Username</label>
              <input class="my-2 form-control" value="` + memberApp_.user.username + `" type="text" name='sponsor[username]'></input>
              

              <button class="mt-4 btn btn-outline-primary checkUser">Check</button>
              <button class="mt-4 btn btn-primary disabled selectUser">Select this user</button>
            </div>
          </div>
          `,
                    header: 'Change Stockist User',
                })
                $(".checkUser").click(() => {


                    phxApp_.api("get_stockist", {
                            parent_id: memberApp_.user.id,
                            show_rank: true,
                            username: $("[name='sponsor[username]']").val(),

                        }, () => {
                            window.stockistTarget = memberApp_.user.username
                            $("input[name='user[stockist_user_id]']").val(null)

                            $(".selectUser").addClass("disabled")

                        },
                        (res) => {

                            $(".selectUser").removeClass("disabled")
                                // $(".pv-info").customHtml(`Accumulated sales PV: ` + res[0] + ` | Rank: ` + res[1])

                            if (res[1].is_stockist) {
                                window.stockistTargetData = res[2]
                                $("input[name='user[stockist_user_id]']").val(window.stockistTargetData.id)
                                phxApp_.notify("User verified!")

                            } else {
                                phxApp_.notify("Not stockist!", {
                                    type: "warning"
                                })
                                $(".selectUser").addClass("disabled")

                            }



                        })


                })
                $(".selectUser").click(() => {
                    $("input[name='user[stockist]']").val($("[name='sponsor[username]']").val())
                    $("input[name='view[stockist]']").val($("[name='sponsor[username]']").val())
                    phxApp_.notify("User selected!")

                    $("#mySubModal").modal('hide')
                    window.stockistTarget = $("[name='sponsor[username]']").val()
                    $("#stockistTarget").html($("[name='sponsor[username]']").val())

                    commerceApp_.components["cartItems"]()





                })
            })

        },


        salesItems() {


            var sale = phxApp_.api("get_sale", {
                id: pageParams.id
            })

            if (sale.status == "pending_payment") {
                if (sale.payment != null) {

                    var res = phxApp_.api("check_bill", {
                        id: sale.payment.billplz_code
                    })

                    if (res.paid == true) {
                        phxApp_.notify("Payment updated!")
                    }
                }
            }
            $("title").html("Order ID: " + sale.id)
            window.sale = sale
            var count = 0,
                list = [],
                total_pv = 0,
                subtotal = 0.0;
            total_pv = sale.sales_items.map((v, i) => {
                return (v.qty * v.item_pv)
            }).reduce((a, b) => {
                return a + b
            }, 0)

            subtotal = sale.sales_items.map((v, i) => {
                return (v.qty * v.item_price)
            }).reduce((a, b) => {
                return a + b
            }, 0)
            count = sale.sales_items.map((v, i) => {
                return v.qty
            }).reduce((a, b) => {
                return a + b
            }, 0)


            shipping_fee = sale.shipping_fee || 0
            eligible_rank = this.evalRank(subtotal)
            try {

                reg_dets = JSON.parse(sale.registration_details)
            } catch (e) {
                console.error(e)
            }
            var is_merchant = false
            if (reg_dets.scope == "merchant_checkout") {
                total_pv = sale.total_point_value
                is_merchant = true
            }

            sale.sales_items.forEach((v, i) => {
                var img = '/images/placeholder.png';
                if (v.img_url != null) {

                    try {
                        img = v.img_url
                    } catch (e) {
                        img = '/images/placeholder.png'
                    }
                }

                var l2 = `  <span class="font-sm text-info "><span class="format-integer">` + (v.item_pv * v.qty) + `</span> PV</span>`
                if (is_merchant) {
                    l2 = ''
                }
                list.push(`

            <div class="d-flex align-items-center justify-content-between gap-2">
              <div class="d-flex align-items-center justify-content-between gap-2">
                <div class="d-flex justify-content-center align-items-center " style="
                                  cursor: pointer;   
                                  position: relative; 
                                  height: 60px;">
                  <div class="rounded py-2" style="
                                  height: 50px;
                                  width: 72%;
                                  filter: blur(4px);
                                  position: absolute;
                                  background-repeat: no-repeat;
                                  background-position: center;
                                  background-size: cover;
                                  background-image: url('` + img + `');
                                  bottom: 6px;
                                  left: 16px;
                                  ">
                  </div>
                  <div class="rounded py-2" style="
                                  height: 50px;
                                  width:  60px;
                                  z-index: 1;
                                  background-position: center;
                                  background-repeat: no-repeat;
                                  background-size: cover; 
                                  background-image: url('` + img + `');
                                  ">
                  </div>
                </div>
                <div class="d-flex flex-column">
                  <span>` + v.item_name + ` <small>(x` + v.qty + `)</small></span>
                  <div>` + v.remarks + `</div>
                </div>
              </div>
              <div class="d-flex flex-column flex-lg-row justify-content-between align-items-center">
                <div class="d-flex flex-column align-items-end">
                  <span class="font-sm ">RP <span class="format-float">` + (v.item_price * v.qty).toFixed(2) + `</span></span>
                ` + l2 + `
                </div>
               
              </div>
            </div>

          
            `)


            })

            var tpv = 'Total PV'

            if (is_merchant) {
                tpv = 'RP Received'
            }


            var payment_info = `

               <div class="d-flex justify-content-between align-items-center">
                  <span class="fs-4">Subtotal</span>
                  <span class=" me-4">RP <span class="format-float">` + subtotal + `</span></span>
                </div>
               <div class="d-flex justify-content-between align-items-center">
                  <span class="fs-4">Shipping</span>
                  <span class=" me-4">RP <span class="format-float">` + shipping_fee + `</span></span>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                  <span class="fs-5">` + tpv + `</span>
                  <span class="text-info me-4"><span class="format-integer">` + total_pv + ` PV</span></span>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                  <span class="fw-bold text-secondary">Eligible Rank</span>
                  <span class="text-info me-4"><span class="format-integer">` + eligible_rank + `</span></span>
                </div>

      `

            try {
                shipping = reg_dets.user.shipping
                console.log("shippnig...")
                console.info(shipping)
                payment = sale.payment
            } catch (e) {
                console.error(e)
            }

            var drp_details = {};
            if (sale.payment != null) {

                if (sale.payment.payment_url != null) {
                    payment_info = `

                 <div class="d-flex justify-content-between align-items-center">
                    <span class="fs-4">Subtotal</span>
                    <span class=" ">RP <span class="format-float">` + subtotal + `</span></span>
                  </div>
                 <div class="d-flex justify-content-between align-items-center">
                    <span class="fs-4">Shipping</span>
                    <span class=" me-4">RP <span class="format-float">` + shipping_fee + `</span></span>
                  </div>
                  <div class="d-flex justify-content-between align-items-center">
                    <span class="fs-5">` + tpv + `</span>
                    <span class="text-info "><span class="format-integer">` + total_pv + ` PV</span></span>
                  </div>
                  <div class="d-flex justify-content-between align-items-center">
                    <span class="fw-bold text-secondary">Eligible Rank</span>
                    <span class="text-info "><span class="format-integer">` + eligible_rank + `</span></span>
                  </div>
                  <div class="d-flex justify-content-between align-items-center">
                    <span class="fw-bold text-secondary">Paid with</span>
                    <span class="text-primary "><span class="">` + (payment.payment_method.split("_").map((v, i) => {
                        return ColumnFormater.capitalize(v)

                    }).join(" ")) + `</span></span>
                  </div>
                  <div class="d-flex justify-content-between align-items-center">
                    <span class="fw-bold text-secondary">Payment Link</span>
                    <span class="text-primary "><a target="_blank" href="` + payment.payment_url + `" class="">` + payment.payment_url + `</a></span>
                  </div>

        `
                }
                try {
                    console.info(sale.payment)
                    if (sale.payment.webhook_details != null) {

                        sale.payment.webhook_details.split("|").map((v, i) => {

                            data = v.split(": ")
                            var key = data[0].replace(" ", "_")
                            console.log(key)
                            drp_details[key] = parseFloat(data[1])


                        })
                        console.info(drp_details)

                        drp_amount = 0
                        var dpp = `DRP`
                        if (is_merchant) {
                            dpp = 'Merchant Point'
                        }
                        if (drp_details.drp_paid != null || drp_details.mp_paid != null) {

                            drp_amount = drp_details.drp_paid
                            if (is_merchant) {
                                drp_amount = drp_details.mp_paid
                            }
                        }
                        if (drp_details.pp_paid != null) {
                            total_pv = 0
                        }
                        var tt4 = (total_pv - drp_amount)
                        var tt5 = (subtotal + shipping_fee - drp_amount - (drp_details.rp_paid || 0))
                        var elb = ` <div class="d-flex justify-content-between align-items-center">
                    <span class="fw-bold text-secondary">Eligible Rank</span>
                    <span class="text-info "><span class="format-integer">` + eligible_rank + `</span></span>
                  </div>`
                        if (is_merchant) {
                            elb = ''
                            tt4 = total_pv
                            tt5 = (subtotal + shipping_fee)
                        }


                        payment_info = `

                 <div class="d-flex justify-content-between align-items-center">
                    <span class="fs-5">Subtotal</span>
                    <span class=" ">RP <span class="format-float">` + subtotal + `</span></span>
                  </div>
                 <div class="d-flex justify-content-between align-items-center">
                    <span class="fs-5">Shipping + Tax</span>
                    <span class=" ">RP <span class="format-float">` + shipping_fee + `</span></span>
                  </div>

                  <div class="d-flex justify-content-between align-items-center">
                    <span class="fs-5">` + dpp + `</span>
                    <span class=" ">- RP <span class="format-float">` + drp_amount + `</span></span>
                  </div>

                 <div class="d-flex justify-content-between align-items-center">
                    <span class="fs-5">Grand Total </span>
                    <span class=" ">RP <span class="format-float">` + (subtotal + shipping_fee) + `</span></span>
                  </div>

                  <div class="d-flex justify-content-between align-items-center">
                    <span class="fs-5">` + tpv + `</span>
                    <span class="text-info "><span class="format-integer">` + tt4 + ` PV</span></span>
                  </div>
                  <div class="d-flex justify-content-between align-items-center">
                    <span class="fs-4">Grand Total  After Payment</span>
                    <span class=" ">RP <span class="format-float">` + tt5 + ` </span></span>
                  </div>

                 ` + elb + `
                  <div class="d-flex justify-content-between align-items-center">
                    <span class="fw-bold text-secondary">Paid with</span>
                    <span class="text-primary "><span class="">` + (payment.payment_method.split("_").map((v, i) => {
                            return ColumnFormater.capitalize(v)

                        }).join(" ")) + `</span></span>
                          </div>

                `




                    }
                } catch (e) {
                    console.error(e)
                }

            }

            var addre = `      `
            try {

                if (shipping != null) {
                    addre = `
          <span class="text-secondary">Deliver To:</span> 
                           <span>` + shipping.line1 + `, ` + shipping.line2 + `</span>
                           <span>` + shipping.city + ` ` + shipping.postcode + `, ` + shipping.state + ` </span>

      `

                } else {
                    shipping = {
                        phone: null,
                        fullname: null
                    }
                }

                if (sale.pick_up_point != null) {
                    addre =

                        `           <span class="text-secondary">Pick Up Point: </span>
                        <span>` + sale.pick_up_point.name + ` </span>
                      <span>` + sale.pick_up_point.address + ` </span>

          `

                }

            } catch (e) {
                console.error(e)
            }






            console.info(addre)



            var print_or_check = `    <a class="btn btn-primary" href="/pdf?id=` + sale.id + `" target="_blank">Print</a>`



            if (sale.payment == null && sale.status == "pending_payment") {
                print_or_check = `<div class="btn btn-success approve-sale" aria-id="` + sale.id + `">Approve</div>`
            }


            if (sale.merchant_id != null) {
                print_or_check = `   <a class="btn btn-primary" href="/pdf?type=merchant&id=` + sale.id + `" target="_blank">Print</a>  <a class="d-none mdo btn btn-primary" href="/pdf?type=merchant_do&id=` + sale.id + `" target="_blank">Print DO</a>`
            }
            console.info(sale)

            $("salesItems").customHtml(`
        <div class="d-flex align-items-center justify-content-between gap-2">
          <h2>Sales Details</h2><small class="badge bg-primary">` + sale.status + `</small>
        </div>
                <div class="d-flex flex-column mb-4 ">
                   <span class="text-secondary">Sold To:</span> 
                   <span>` + (reg_dets.user.fullname || phxApp_.user.fullname) + `, ` + (reg_dets.user.phone || phxApp_.user.phone) + `</span>
                   
                </div>
                <div class="d-flex flex-column mb-4 ">
                   <span class="text-secondary">Recipient:</span> 
                   <span>` + (shipping.fullname || phxApp_.user.fullname) + `, ` + (shipping.phone || phxApp_.user.phone) + `</span>
                   
                </div>


                <div class="d-flex flex-column mb-4 ">
                 
                    ` + addre + `
                </div>

                   <span class="text-secondary">Items:</span>
                <div class="d-flex flex-column gap-2">` + list.join("") + `
                ` + payment_info + `
                </div>
                <div class="my-4">
              ` + print_or_check + `
                </div>

        `)

            $(".approve-sale").click(function() {
                var id = $(this).attr("aria-id")
                phxApp_.modal({
                    selector: "#mySubModal",
                    content: `<div>

            <p>Approve this sale ?</p>

            <div class="btn btn-outline-primary confirm-approve">Approve</div>

            </div>`,
                    header: "Confirmation",
                    autoClose: false
                })



                $(".confirm-approve").click(() => {
                    phxApp_.api("manual_approve_bank_in", {
                        id: id
                    })
                }, null, () => {
                    phxApp_.navigateTo(location.pathname)
                })

            })




            ColumnFormater.formatDate();
        },
        evalStates() {
            $("select[name='user[shipping][state]']").customHtml(`<option></option>`)
            var malaysia = phxApp_.countries_.filter((v, i) => {
                return v.name == "Malaysia"
            })[0]
            if (malaysia.id == phxApp_.chosen_country_id_.id) {


                if ($("[name='user[pick_up_point_id]']").val() == null) {

                    $(".ss1").customHtml(`
                <select class="form-select" required id="s1" onchange="window.choosenAddress = null" name="user[shipping][state]">
                </select>
                <label class="ms-2" for="floatingInput">State</label>
          `)
                } else {
                    $(".ss1").customHtml(`
                <select class="form-select"  id="s1" onchange="window.choosenAddress = null" name="user[shipping][state]">
                </select>
                <label class="ms-2" for="floatingInput">State</label>
          `)
                }
                var states = [
                    ["jhr", "Johor"],
                    ["kdh", "Kedah"],
                    ["ktn", "Kelantan"],
                    ["mlk", "Melaka"],
                    ["nsn", "Negeri Sembilan"],
                    ["phg", "Pahang"],
                    ["prk", "Perak"],
                    ["pls", "Perlis"],
                    ["png", "Pulau Pinang"],
                    ["sgr", "Selangor"],
                    ["trg", "Terengganu"],
                    ["kul", "Kuala Lumpur"],
                    ["pjy", "Putra Jaya"],
                    ["srw", "Sarawak"],
                    ["sbh", "Sabah"],
                    ["lbn", "Labuan"]
                ]
                states.forEach((v, i) => {
                    if (window.selectedState == v[1]) {
                        $("select[name='user[shipping][state]']").append(`
              <option selected value="` + v[1] + `">` + v[1] + `</option>`)
                    } else {
                        $("select[name='user[shipping][state]']").append(`
              <option value="` + v[1] + `">` + v[1] + `</option>`)
                    }
                })
                $("select[name='user[shipping][state]']").change(() => {
                    window.selectedState = $("select[name='user[shipping][state]']").val()
                    commerceApp_.components["updateCart"]()
                    commerceApp_.components["cartItems"]()
                })
            } else {
                if ($("[name='user[pick_up_point_id]']").val() == null) {

                    $(".ss1").customHtml(`
                <input class="form-control" required id="s1" onchange="window.choosenAddress = null" name="user[shipping][state]">
                </input>
                <label class="ms-2" for="floatingInput">State</label>
          `)
                } else {

                    $(".ss1").customHtml(`
                <input class="form-control"  id="s1" onchange="window.choosenAddress = null" name="user[shipping][state]">
                </input>
                <label class="ms-2" for="floatingInput">State</label>
          `)
                }
            }


        },
        evalShipping(subtotal) {
            var is_merchant = $("cartItems").attr("merchant") == "" ? true : false;
            var s = 0

            var malaysia = phxApp_.countries_.filter((v, i) => {
                return v.name == "Malaysia"
            })[0]

            var singapore = phxApp_.countries_.filter((v, i) => {
                return v.name == "Singapore"
            })[0]
            if (malaysia.id == phxApp_.chosen_country_id_.id) {
                if ($("[name='user[pick_up_point_id]']").val() != "") {
                    s = 0
                } else {

                    if (["Sabah", "Sarawak", "Labuan"].includes(window.selectedState)) {
                        s = Math.ceil(subtotal / 200) * 4
                    } else {
                        if (is_merchant) {
                            s = Math.ceil(subtotal / 200) * 2
                        } else {

                            if (subtotal >= 36) {
                                s = 0
                            } else {
                                s = 2
                            }
                        }
                    }
                }

            } else {
                s = subtotal * 0.10
                if (singapore.id == phxApp_.chosen_country_id_.id) {
                    s = subtotal * 0.05

                    if (is_merchant) {
                        s = subtotal * 0.10
                    }
                }
            }


            return s
        },
        evalShippingAddresses() {


            try {
                phxApp_.api("list_pick_up_point_by_country", {
                    country_id: phxApp_.chosen_country_id_.id
                }, null, (list) => {
                    phxApp_.pick_up_points = list

                    if ($("[name='user[pick_up_point_id]']").length > 0) {

                        if ($("[name='user[pick_up_point_id]']").val() != "") {
                            var id = $("[name='user[pick_up_point_id]']").val()
                            var pup = phxApp_.pick_up_points.filter((v, i) => {
                                return v.id == id
                            })[0]
                            try {
                                $("[name='user[shipping][state]']").removeAttr("required")
                                console.log("attr removed")
                                $(".self-pickup-form").customHtml(`
                   <div class="d-flex flex-column">
                      <span>` + pup.name + `</span>
                      <span class="text-secondary">` + pup.address + `</span>
                      <span class="mt-4">
                      </span>
                    </div>

            `)
                            } catch (e) {
                                $(".shipping-form").removeClass("d-none")
                                $(".self-pickup-form").addClass("d-none")
                                phxApp_.notify("No pick up points in this region", {
                                    type: "danger"
                                })

                            }
                        }
                    }


                    var adds = []
                    list.forEach((v, i) => {
                        adds.push(`
              <div class="card my-2" style="cursor: pointer;">
                <div class="card-body">
                  <div class="d-flex flex-column">
                    <span>` + v.name + `</span>
                    <span class="text-secondary">` + v.address + `</span>
                    <span class="mt-4">
                      <div class="btn btn-primary" aria-address="` + v.id + `">Choose</div>
                    </span>
                  </div>
                </div>
              </div>
            `)
                    })
                    $(".self-pickup").unbind()
                    $(".self-pickup").click(() => {
                        window.selectedState = null


                        $(".shipping-form").addClass("d-none")
                        $(".self-pickup-form").removeClass("d-none")
                        phxApp_.modal({
                            autoClose: false,
                            selector: "#mySubModal",
                            content: `
            <div class="d-flex flex-column">
              ` + adds.join("") + `
            </div>
            `,
                            header: "Pick Up Points"
                        })
                        $("[aria-address]").click(function() {
                            var id = $(this).attr("aria-address")

                            var pup = phxApp_.pick_up_points.filter((v, i) => {
                                return v.id == id
                            })[0]
                            try {
                                $("[name='user[shipping][state]']").removeAttr("required")
                                console.log("attr removed")
                                $(".self-pickup-form").customHtml(`
                   <div class="d-flex flex-column">
                      <span>` + pup.name + `</span>
                      <span class="text-secondary">` + pup.address + `</span>
                      <span class="mt-4">
                      </span>
                    </div>

            `)
                            } catch (e) {
                                $(".shipping-form").removeClass("d-none")
                                $(".self-pickup-form").addClass("d-none")
                                phxApp_.notify("No pick up points in this region", {
                                    type: "danger"
                                })

                            }
                            $("[name='user[pick_up_point_id]']").val(id)

                            $("#mySubModal").modal('hide')
                            $("[name='user[shipping][state]']").val(null)

                            commerceApp_.components["cartItems"]()
                        })
                    })
                })
                if (pageParams.share_code != null) {

                } else {
                    // if its an instalment



                    phxApp_.api("list_user_sales_addresses_by_username", {
                        username: phxApp_.user.username
                    }, null, (list) => {
                        phxApp_.addresses = list
                        if (list.length > 0) {
                            if (window.choosenAddress != null) {

                                var address = list.filter((v, i) => {
                                    return v.id == window.choosenAddress
                                })[0]
                                $("[name='user[shipping][phone]']").val(address.phone)
                                $("[name='user[shipping][fullname]']").val(address.fullname)
                                $("[name='user[shipping][line1]']").val(address.line1)
                                $("[name='user[shipping][line2]']").val(address.line2)
                                $("[name='user[shipping][city]']").val(address.city)
                                $("[name='user[shipping][postcode]']").val(address.postcode)
                                setTimeout(() => {
                                    $("[name='user[shipping][state]']").val(address.state)
                                }, 500)
                            }
                        }
                        $(".change-address").unbind()
                        var adds = []
                        list.forEach((v, i) => {
                            adds.push(`
              <div class="card my-2" style="cursor: pointer;">
                <div class="card-body">
                  <div class="d-flex flex-column">
                    <span>` + v.fullname + `</span>
                    <span class="text-secondary">` + v.line1 + `, ` + v.line2 + `</span>
                    <span class="mt-4">
                      <div class="btn btn-primary" aria-address="` + v.id + `">Choose</div>
                    </span>
                  </div>
                </div>
              </div>
            `)
                        })
                        $(".change-address").click(() => {
                            $("[name='user[pick_up_point_id]']").val("")
                            $(".shipping-form").removeClass("d-none")
                            $(".self-pickup-form").addClass("d-none")
                            $("[name='user[shipping][state]']").attr("required")
                            console.log("attr add")
                            phxApp_.modal({
                                autoClose: false,
                                selector: "#mySubModal",
                                content: `
            <div class="d-flex flex-column">
              ` + adds.join("") + `
            </div>
            `,
                                header: "Change address"
                            })
                            $("[aria-address]").click(function() {
                                var id = $(this).attr("aria-address")
                                window.choosenAddress = id
                                var address = phxApp_.addresses.filter((v, i) => {
                                    return v.id == id
                                })[0]
                                $("[name='user[shipping][phone]']").val(address.phone)
                                $("[name='user[shipping][fullname]']").val(address.fullname)
                                $("[name='user[shipping][line1]']").val(address.line1)
                                $("[name='user[shipping][line2]']").val(address.line2)
                                $("[name='user[shipping][city]']").val(address.city)
                                $("[name='user[shipping][postcode]']").val(address.postcode)
                                setTimeout(() => {
                                    $("[name='user[shipping][state]']").val(address.state)
                                }, 500)
                                $("#mySubModal").modal('hide')
                                commerceApp_.components["cartItems"]()
                            })
                        })
                    })
                }



            } catch (e) {
                console.error(e)
            }

        },
        cartItems() {


            var is_merchant = $("cartItems").attr("merchant") == "" ? true : false;
            const cart = is_merchant ? commerceApp_.mcart_ : commerceApp_.cart_;
            var hasOverride = false,
                count = 0,
                shipping_fee = 0,
                list = [],
                total_pv = 0,
                subtotal = 0.0;
            total_pv = cart.map((v, i) => {
                return (v.qty * v.point_value)
            }).reduce((a, b) => {
                return a + b
            }, 0)
            subtotal = cart.map((v, i) => {
                return (v.qty * v.retail_price)
            }).reduce((a, b) => {
                return a + b
            }, 0)
            if (is_merchant) {
                total_pv = subtotal
            }
            count = cart.map((v, i) => {
                return v.qty
            }).reduce((a, b) => {
                return a + b
            }, 0)

            this.evalShippingAddresses()

            this.evalStates()

            if ($("cartItems").attr("upgrade") != null) {
                if (window.upgradeTarget != null) {
                    accumulated_sales = phxApp_.api("get_accumulated_sales", {
                        username: window.upgradeTarget
                    })
                    subtotal = subtotal

                    eligible_rank = this.evalRank(subtotal + accumulated_sales)
                } else {
                    subtotal = subtotal

                    eligible_rank = this.evalRank(subtotal + memberApp_.user.rank.retail_price)
                }


                $(".only-downline").click(() => {
                    phxApp_.notify("Only available for direct recruited downline.")
                })
            } else {
                eligible_rank = this.evalRank(subtotal)
            }
            shipping_fee = this.evalShipping(subtotal)


            cart.forEach((v, i) => {


                var lpv = `<span class="font-sm text-info "><span class="format-integer">` + (v.point_value * v.qty) + `</span> PV</span>`

                if (is_merchant) {
                    lpv = ``
                }

                var img = '/images/placeholder.png';
                if (v.img_url != null) {

                    try {
                        img = v.img_url
                    } catch (e) {
                        img = '/images/placeholder.png'
                    }
                }

                var linePassed = '';

                if (cart == commerceApp_.cart && parseInt(localStorage.first_cart_country_id) != phxApp_.chosen_country_id_.id) {

                    linePassed = `border border-danger`

                    list.push(`

            <div class="d-flex align-items-center justify-content-between gap-2 ` + linePassed + ` rounded p-2 me-3">
           
              <div class="d-flex align-items-center justify-content-between gap-2">
                <div class="d-flex justify-content-center align-items-center " style="
                                  cursor: pointer;   
                                  position: relative; 
                                  height: 60px;">
                  <div class="rounded py-2" style="
                                  height: 50px;
                                  width: 72%;
                                  filter: blur(4px);
                                  position: absolute;
                                  background-repeat: no-repeat;
                                  background-position: center;
                                  background-size: cover;
                                  background-image: url('` + img + `');
                                  bottom: 6px;
                                  left: 16px;
                                  ">
                  </div>
                  <div class="rounded py-2" style="
                                  height: 50px;
                                  width:  60px;
                                  z-index: 1;
                                  background-position: center;
                                  background-repeat: no-repeat;
                                  background-size: cover; 
                                  background-image: url('` + img + `');
                                  ">
                  </div>
                </div>
                <span>` + v.name + ` <small>(x` + v.qty + `)</small> <br><small> <i class="fa fa-exclamation-triangle text-danger "></i>Product not available for this region</small></span>
              </div>
              <div class="d-flex flex-column flex-lg-row justify-content-between align-items-center">
                
                <div class="text-center">
                  <div class="btn btn-sm" delete-product-id="` + v.id + `"><i class="text-danger fa fa-times"></i></div>
                </div>
              </div>
            </div>

          
            `)
                } else {

                    if (v.override_pv) {
                        hasOverride = true
                    }

                    var rp = `RP <span class="format-float">` + (v.retail_price * v.qty).toFixed(2) + ``
                    if (showRP == false) {

                        rp = `MYR <span class="format-float">` + (v.retail_price * v.qty * phxApp_.chosen_country_id_.conversion).toFixed(2) + ``
                    }
                    var instalment_input = ``,
                        instalment_info = ``



                    if (v.selectedInstalmentId != null) {
                        var instalment = v.selectedInstalment
                        try {

                            instalment_info = `<div class="text-sm text-secondary">` + instalment.name + `</div>`
                            instalment_input = `<input type="hidden"  name="user[products][` + i + `][remarks]" value="instalment_product_id:` + v.selectedInstalmentId + `">`
                        } catch (e) {
                            console.error(e)
                        }
                    }

                    try {
                        if ($("input[name='user[instalment]']").val() != null) {

                            var form_instalment_info = $("input[name='user[instalment]']").val()
                            instalment_info = form_instalment_info
                        }
                        // very likely this is for the repurchase....
                    } catch (e) {
                        console.error(e)
                    }


                    list.push(`

              <div class="d-flex align-items-center justify-content-between gap-2 ` + linePassed + ` rounded p-2 me-3">
              <input type="hidden"  name="user[products][` + i + `][item_name]" value="` + v.name + `">
              <input type="hidden"  name="user[products][` + i + `][item_price]" value="` + v.retail_price + `">
              <input type="hidden"  name="user[products][` + i + `][item_pv]" value="` + v.point_value + `">
              <input type="hidden"  name="user[products][` + i + `][img_url]" value="` + v.img_url + `">
              <input type="hidden"  name="user[products][` + i + `][qty]" value="` + v.qty + `">
              ` + instalment_input + `
                <div class="d-flex align-items-center justify-content-between gap-2">
                  <div class="d-flex justify-content-center align-items-center " style="
                                    cursor: pointer;   
                                    position: relative; 
                                    height: 60px;">
                    <div class="rounded py-2" style="
                                    height: 50px;
                                   width: 72%;
                                    filter: blur(4px);
                                    position: absolute;
                                    background-repeat: no-repeat;
                                    background-position: center;
                                    background-size: cover;
                                    background-image: url('` + img + `');
                                    bottom: 6px;
                                    left: 16px;
                                    ">
                    </div>
                    <div class="rounded py-2" style="
                                    height: 50px;
                                    width:  60px;
                                    z-index: 1;
                                    background-position: center;
                                    background-repeat: no-repeat;
                                    background-size: cover; 
                                    background-image: url('` + img + `');
                                    ">
                    </div>
                  </div>
                  <div class="d-flex flex-column">
                    <span>` + v.name + ` <small>(x` + v.qty + `)</small></span>
                    ` + instalment_info + `
                  </div>
                </div>
                <div class="d-flex flex-column flex-lg-row justify-content-between align-items-center">
                  <div class="d-flex flex-column align-items-end">
                    <span class="font-sm ">` + rp + `</span></span>
                    ` + lpv + `
                  </div>
                  <div class="text-center">
                    <div class="btn btn-sm" add-product-id="` + v.id + `"><i class="text-info fa fa-plus"></i></div>
                    <div class="btn btn-sm" minus-product-id="` + v.id + `"><i class="text-danger fa fa-minus"></i></div>
                    <div class="btn btn-sm" delete-product-id="` + v.id + `"><i class="text-danger fa fa-times"></i></div>
                  </div>
                </div>
              </div>

            
              `)
                }



            })




            var has_instalment_info = false;

            try {
                if ($("input[name='user[instalment]']").val() != null) {

                    has_instalment_info = true

                }
                // very likely this is for the repurchase....
            } catch (e) {
                console.error(e)
            }


            try {
                if ($("input[name='user[stockist_user_id]']").val() != null) {

                    shipping_fee = 0

                }
                // very likely this is for the repurchase....
            } catch (e) {
                console.error(e)
            }
            if (has_instalment_info) {
                shipping_fee = 0
            }
            console.log("merchant?")
            console.log(is_merchant)
            if (is_merchant) {
                shipping_fee = subtotal * 0.025
                shipping_fee = 0
            }




            var currency = `RP`,
                srp = (subtotal + shipping_fee),
                cshipping_fee = shipping_fee,
                elr = `

                  <div class="d-flex justify-content-between align-items-center">
                    <span class="fw-bold text-secondary">Eligible Rank</span>
                    <span class="text-info me-4"><span class="format-integer">` + eligible_rank + `</span></span>
                  </div>

    `,
                tpv = `

      Total PV

    `,
                crp = `RP <span class="format-float">` + subtotal + ``

            if (is_merchant) {
                elr = ''
                tpv = `RP received`
            }
            if (!showRP) {
                crp = `MYR <span class="format-float">` + (subtotal * phxApp_.chosen_country_id_.conversion) + ``
                cshipping_fee = shipping_fee * phxApp_.chosen_country_id_.conversion
                srp = (subtotal + shipping_fee) * phxApp_.chosen_country_id_.conversion
                currency = `MYR`
            }

            $("cartItems").customHtml(`

                  <div class="d-flex flex-column gap-1">` + list.join("") + `
                    <div class="d-flex justify-content-between align-items-center">
                      <span class="fw-bold">Subtotal</span>
                      <span class=" me-4">` + crp + `</span></span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                      <span class="fw-bold">Shipping_Tax</span>
                      <span class=" me-4">` + currency + ` <span class="format-float">` + cshipping_fee + `</span></span>
                    </div>

                    <div class="d-flex justify-content-between align-items-center">
                      <span class="fs-4">Grand Total</span>
                      <span class=" me-4">` + currency + ` <span class="format-float fs-4">` + srp + `</span></span>
                    </div>
                  <div class="d-flex justify-content-between align-items-center pv_label d-none">
                    <span class="fs-5">` + tpv + `</span>
                    <span class="text-info me-4"><span class="format-integer">` + total_pv + ` PV</span></span>
                  </div>
                  ` + elr + `

                </div>

 

        `)

            var user = memberApp_.user,
                wallets = []

            if (user != null) {

                if (user.wallets == null) {
                    wallets = phxApp_.api("user_wallet", {
                        token: user.token
                    })
                    user.wallets = wallets
                } else {
                    wallets = user.wallets
                }
            }


            function appendWalletAttr() {
                if (wallets.length == 0) {} else {
                    $("wallet").each((i, v) => {
                        var check = wallets.filter((wv, wi) => {
                            return wv.wallet_type == "direct_recruitment"
                        })

                        if (is_merchant) {
                            check = wallets.filter((wv, wi) => {
                                return wv.wallet_type == "merchant"
                            })

                        }

                        // DRP use
                        if (check.length > 0) {
                            var wallet = check[0]

                            if (is_merchant) {
                                $("#drp_payment").attr("max", subtotal * 0.2)
                                $("#drp_payment").attr("min", 0)
                                $("#drp_payment").attr("step", 0.01)
                                $("#drp_payment").attr("value", subtotal * 0.2)

                            } else {

                                // check if the cart has item that's override_pv 
                                if (hasOverride) {
                                    var reg_pv = subtotal * 0.7;

                                    console.info("here ovier")
                                    var subtotal2 = cart.map((v, i) => {
                                        return (v.qty * v.retail_price * v.override_perc)
                                    }).reduce((a, b) => {
                                        return a + b
                                    }, 0)



                                    $("#drp_payment").attr("min", Math.round(subtotal2))
                                    $("#drp_payment").attr("value", Math.round(subtotal2))
                                } else {
                                    $("#drp_payment").attr("max", wallet.total)
                                    $("#drp_payment").attr("min", Math.round(subtotal * 0.5))
                                    $("#drp_payment").attr("value", Math.round(subtotal * 0.5))

                                }

                            }
                        } else {}
                    })
                }
            }
            $("input[name='user[payment][method]']").unbind()
            $("input[name='user[payment][method]']").on("change", () => {
                $("#coupon-detail").addClass("d-none")

                $("input[name='user[payment][method]']").each((i, v) => {

                    if ($(v)[0].checked == true) {

                        if (["register_point", "merchant_point"].includes($(v).val())) {
                            $("#coupon-detail").removeClass("d-none")

                            drpChanged()
                        } else {

                            $("#drp_payment").removeAttr("max")
                            $("#drp_payment").removeAttr("min")
                            $("#drp_payment").removeAttr("value")
                            if (is_merchant) {
                                commerceApp_.components["updateMCart"]()

                            } else {

                                commerceApp_.components["updateCart"]()
                            }
                            commerceApp_.components["cartItems"]()
                        }

                    }
                })


            })


            function drpChanged() {
                appendWalletAttr()
                var drp_amount = 0,
                    shipping_fee = 2,
                    tt3 = 0,
                    tt4 = 0;
                if ($("#drp_payment").length > 0) {
                    try {

                        drp_amount = parseFloat($("#drp_payment").val())
                    } catch (e) {
                        drp_amount = $("#drp_payment").val()
                    }
                }
                shipping_fee = commerceApp_.components.evalShipping(subtotal)
                if (has_instalment_info) {
                    shipping_fee = 0.0
                }
                tt3 = (subtotal + shipping_fee - drp_amount);
                tt4 = (total_pv - drp_amount)
                if (is_merchant) {
                    shipping_fee = subtotal * 0.025
                    shipping_fee = 0
                    tt3 = (subtotal + shipping_fee)
                    console.log("w")
                    tt4 = subtotal - drp_amount + shipping_fee
                } else {

                }



                var drpa = `


                    <div class="d-flex justify-content-between align-items-center">
                      <span class="fw-bold">DRP</span>
                      <span class=" me-4">- RP <span class="format-float">` + drp_amount + `</span></span>
                    </div>
        `

                if (is_merchant) {
                    drpa = `


                    <div class="d-flex justify-content-between align-items-center">
                      <span class="fw-bold">MP</span>
                      <span class=" me-4">- RP <span class="format-float">` + drp_amount + `</span></span>
                    </div>
          `
                }



                $("cartItems").customHtml(`

                  <div class="d-flex flex-column gap-1">` + list.join("") + `
                    <div class="d-flex justify-content-between align-items-center">
                      <span class="fw-bold">Subtotal</span>
                      <span class=" me-4">RP <span class="format-float">` + subtotal + `</span></span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                      <span class="fw-bold">Shipping_Tax</span>
                      <span class=" me-4">RP <span class="format-float">` + shipping_fee + `</span></span>
                    </div>
                    ` + drpa + `
                    <div class="d-flex justify-content-between align-items-center">
                      <span class="fs-4">Grand Total</span>
                      <span class=" me-4">RP <span class="format-float fs-4">` + tt3 + `</span></span>
                    </div>

                    <div class="d-flex justify-content-between align-items-center pv_label d-none">
                      <span class="fs-5">` + tpv + `</span>
                      <span class="text-info me-4"><span class="format-integer">` + tt4 + ` PV</span></span>
                    </div>
                   ` + elr + `
                  </div>


          `)




                if (is_merchant) {
                    $("cartItems").customHtml(`

                            <div class="d-flex flex-column gap-1">` + list.join("") + `
                              <div class="d-flex justify-content-between align-items-center">
                                <span class="fw-bold">Subtotal</span>
                                <span class=" me-4">RP <span class="format-float">` + subtotal + `</span></span>
                              </div>
                              <div class="d-flex justify-content-between align-items-center">
                                <span class="fw-bold">Shipping_Tax</span>
                                <span class=" me-4">RP <span class="format-float">` + shipping_fee + `</span></span>
                              </div>
                              ` + drpa + `
                              <div class="d-flex justify-content-between align-items-center">
                                <span class="fs-4">Grand Total</span>
                                <span class=" me-4">RP <span class="format-float fs-4">` + tt4 + `</span></span>
                              </div>

                              <div class="d-flex justify-content-between align-items-center pv_label d-none">
                                <span class="fs-5">` + tpv + `</span>
                                <span class="text-info me-4"><span class="format-integer">` + tt4 + ` PV</span></span>
                              </div>
                             ` + elr + `
                            </div>


                    `)

                }


                ColumnFormater.formatDate();
                $("[add-product-id]").each((i, v) => {
                    var id = $(v).attr("add-product-id")

                    function addItem() {
                        commerceApp_.addItemById_(id, is_merchant)
                        if (is_merchant) {
                            commerceApp_.components["updateMCart"]()
                        } else {
                            commerceApp_.components["updateCart"]()
                        }
                        commerceApp_.components["cartItems"]()
                        commerceApp_.toastChanges()

                    }
                    $(v)[0].onclick = addItem
                })
                $("[minus-product-id]").each((i, v) => {
                    var id = $(v).attr("minus-product-id")

                    function minusItem() {
                        commerceApp_.minusItem_(id, is_merchant)
                        if (is_merchant) {
                            commerceApp_.components["updateMCart"]()
                        } else {
                            commerceApp_.components["updateCart"]()
                        }
                        commerceApp_.components["cartItems"]()
                        commerceApp_.toastChanges()

                    }
                    $(v)[0].onclick = minusItem
                })

                $("[delete-product-id]").each((i, v) => {
                    var id = $(v).attr("delete-product-id")

                    function deleteItem() {
                        commerceApp_.removeItem_(id, is_merchant)
                        if (is_merchant) {
                            commerceApp_.components["updateMCart"]()
                        } else {
                            commerceApp_.components["updateCart"]()
                        }
                        commerceApp_.components["cartItems"]()
                        commerceApp_.toastChanges()
                    }
                    $(v)[0].onclick = deleteItem
                })
            }


            function drpChangeHandler(event) {

                $("#drp_payment").removeAttr("max")
                $("#drp_payment").removeAttr("min")
                $("#drp_payment").removeAttr("value")

                drpChanged()
            }

            drp_elem = document.getElementById("drp_payment")
            if (drp_elem != null) {
                drp_elem.removeEventListener("change", drpChangeHandler)
                drp_elem.addEventListener("change", drpChangeHandler)
            }

            $("[add-product-id]").each((i, v) => {
                var id = $(v).attr("add-product-id")

                function addItem() {
                    commerceApp_.addItemById_(id, is_merchant)
                    if (is_merchant) {
                        commerceApp_.components["updateMCart"]()
                    } else {
                        commerceApp_.components["updateCart"]()
                    }
                    commerceApp_.components["cartItems"]()
                    commerceApp_.toastChanges()

                }
                $(v)[0].onclick = addItem
            })
            $("[minus-product-id]").each((i, v) => {
                var id = $(v).attr("minus-product-id")

                function minusItem() {
                    commerceApp_.minusItem_(id, is_merchant)
                    if (is_merchant) {
                        commerceApp_.components["updateMCart"]()
                    } else {
                        commerceApp_.components["updateCart"]()
                    }
                    commerceApp_.components["cartItems"]()
                    commerceApp_.toastChanges()

                }
                $(v)[0].onclick = minusItem
            })

            $("[delete-product-id]").each((i, v) => {
                var id = $(v).attr("delete-product-id")

                function deleteItem() {
                    commerceApp_.removeItem_(id, is_merchant)
                    if (is_merchant) {
                        commerceApp_.components["updateMCart"]()
                    } else {
                        commerceApp_.components["updateCart"]()
                    }
                    commerceApp_.components["cartItems"]()
                    commerceApp_.toastChanges()
                }
                $(v)[0].onclick = deleteItem
            })


            $("input[name='user[payment][method]']").each((i, v) => {

                if ($(v)[0].checked == true) {

                    if (["register_point", "merchant_point"].includes($(v).val())) {
                        $("#coupon-detail").removeClass("d-none")

                        drpChanged()
                    } else {
                        $("#drp_payment").removeAttr("max")
                        $("#drp_payment").removeAttr("min")
                        $("#drp_payment").removeAttr("value")
                    }

                }
            })



            ColumnFormater.formatDate();
        },
        evalRank(subtotal) {


            var sort = [];
            memberApp_.ranks.map((v, i) => {
                sort.push(v)
            })

            sort.sort((a, b) => {
                return b.retail_price - a.retail_price
            })


            check = sort.filter((v, i) => {
                return v.retail_price <= subtotal
            })[0]

            var eligible_rank = "n/a"
            console.log(eligible_rank)

            if (check) {
                eligible_rank = check.name
                if ($("input[name='user[rank_id]']").length > 0) {

                    $("input[name='user[rank_id]']").val(check.id)
                }
            }

            return eligible_rank
        },
        updateCart() {
            var count = 0,
                list = [],
                subtotal = 0.0;

            subtotal = commerceApp_.cart_.map((v, i) => {
                return (v.qty * v.retail_price)
            }).reduce((a, b) => {
                return a + b
            }, 0)
            count = commerceApp_.cart_.map((v, i) => {
                return v.qty
            }).reduce((a, b) => {
                return a + b
            }, 0)

            $(".bc").html(count)

            commerceApp_.cart_.forEach((v, i) => {

                var frp = `<div class="font-sm">RP <span class="font-sm format-float">` + (v.retail_price * v.qty).toFixed(2) + `</span></div>`
                if (!showRP) {
                    frp = `<div class="font-sm">MYR <span class="font-sm format-float">` + (v.retail_price * v.qty * phxApp_.chosen_country_id_.conversion).toFixed(2) + `</span></div>`

                }


                list.push(`

          <li><a class="dropdown-item" href="javascript:void(0);">
            <div style="width: 240px;" class="d-flex justify-content-between align-items-center">
              <span>` + v.name + ` <small>(x` + v.qty + `)</small></span>
              <div class="d-flex align-items-center justify-content-between gap-2">
                ` + frp + `

                <div class="d-lg-block d-none">
                  <div class="btn btn-sm" minus-product-id="` + v.id + `"><i class="text-danger fa fa-minus"></i></div>
                  <div class="btn btn-sm" delete-product-id="` + v.id + `"><i class="text-danger fa fa-times"></i></div>
                </div>
                

              </div>
            </div>

          </a></li>

            `)


            })

            if (list.length == 0) {

                list.push(`

          <li><a class="dropdown-item" href="javascript:void(0);">Empty</a></li>

            `)

            }

            var bg_ranks2 = [],
                sort = [];
            memberApp_.ranks.map((v, i) => {
                sort.push(v)
            })

            sort.sort((a, b) => {
                return a.retail_price - b.retail_price
            })

            sort.map((v, i) => {
                bg_ranks2.push(`
          <div class="col ">
            <div class="d-flex flex-column">
              <span>` + v.name + `</span>
              <span class="format-float">` + v.retail_price + `</span>
              
            </div>
          </div>`)
            })

            // if ($("cartItems").attr("upgrade") != null) {
            //   subtotal = subtotal + memberApp_.user.rank.retail_price

            // }
            // eligible_rank = this.evalRank(subtotal)


            if ($("cartItems").attr("upgrade") != null) {
                if (window.upgradeTarget != null) {
                    accumulated_sales = phxApp_.api("get_accumulated_sales", {
                        username: window.upgradeTarget
                    })
                    subtotal = subtotal
                    console.log(subtotal)
                    eligible_rank = this.evalRank(subtotal + accumulated_sales)
                } else {
                    subtotal = subtotal
                    console.log(subtotal)
                    eligible_rank = this.evalRank(subtotal + memberApp_.user.rank.retail_price)
                }


                $(".only-downline").click(() => {
                    phxApp_.notify("Only available for direct recruited downline.")
                })
            } else {
                subtotal = subtotal
                console.log(subtotal)
                eligible_rank = this.evalRank(subtotal)
            }

            bg_ranks = [

                `  <div class="progress-bar bg-danger" role="progressbar" style="width: 15%;" aria-valuenow="15" aria-valuemin="0" aria-valuemax="100"></div>`,
                `  <div class="progress-bar bg-warning" role="progressbar" style="width: 30%;" aria-valuenow="30" aria-valuemin="0" aria-valuemax="100"></div>`,
                `  <div class="progress-bar bg-info" role="progressbar" style="width: 20%;" aria-valuenow="20" aria-valuemin="0" aria-valuemax="100"></div>`

            ]


            rankSubtotal = memberApp_.ranks.sort((a, b) => {
                return a.retail_price - b.retail_price
            }).findIndex(item => item.name === eligible_rank);
            console.log(rankSubtotal)
            perc = (rankSubtotal + 1) * 25



            $(".ac").each((i, vv) => {


                var html = list.join("") + `
                <li id="divider">
                  <hr class="dropdown-divider">
                </li>
               <li>                  

               <a class="dropdown-item navi" href="/register">
                    <div class="d-flex flex-column">
                      <div class="d-flex justify-content-between align-items-center">
                        <span>Checkout</span>
                        <span class="format-float">` + subtotal + `</span>
                      </div>
                   

                      <div class="d-flex justify-content-between align-items-center">
                        <small>Eligible</small>
                        <small class="text-info">` + eligible_rank + `</small>
                      </div>

                      <div class="progress my-2" style="height: 4px;">
                        <div class="progress-bar bg-success" role="progressbar" style="width: ` + perc + `%;" aria-valuenow="` + perc + `" aria-valuemin="0" aria-valuemax="100"></div>
                      </div>
                      <div class="row text-sm">
                        ` + bg_ranks2.join("") + `
                      </div>

                    
                    </div>
                  </a>
                </li>`


                $(vv).html(html)

            })



            $("[minus-product-id]").each((i, v) => {
                var id = $(v).attr("minus-product-id")

                function minusItem() {
                    commerceApp_.minusItem_(id)
                    commerceApp_.components["updateCart"]()
                    commerceApp_.toastChanges()
                }
                $(v)[0].onclick = minusItem
            })

            $("[delete-product-id]").each((i, v) => {
                var id = $(v).attr("delete-product-id")

                function deleteItem() {
                    commerceApp_.removeItem_(id)
                    commerceApp_.components["updateCart"]()
                    commerceApp_.toastChanges()
                }
                $(v)[0].onclick = deleteItem
            })

            ColumnFormater.formatDate();

        },
        updateMCart() {
            var count = 0,
                list = [],
                subtotal = 0.0;

            subtotal = commerceApp_.mcart_.map((v, i) => {
                return (v.qty * v.retail_price)
            }).reduce((a, b) => {
                return a + b
            }, 0)
            count = commerceApp_.mcart_.map((v, i) => {
                return v.qty
            }).reduce((a, b) => {
                return a + b
            }, 0)

            $(".mbc").html(count)

            commerceApp_.mcart_.forEach((v, i) => {

                list.push(`

          <li><a class="dropdown-item" href="javascript:void(0);">
            <div style="width: 240px;" class="d-flex justify-content-between align-items-center">
              <span>` + v.name + ` <br><small>(x` + v.qty + `)</small></span>
              <div class="d-flex align-items-center justify-content-between gap-2">
                <span class="font-sm format-float">` + (v.retail_price * v.qty).toFixed(2) + `</span>

             
                

              </div>
            </div>

          </a></li>

            `)


            })

            if (list.length == 0) {

                list.push(`

          <li><a class="dropdown-item" href="javascript:void(0);">Empty</a></li>

            `)

            }
            $(".mac").each((i, vv) => {


                var html = list.join("") + `
                <li id="divider">
                  <hr class="dropdown-divider">
                </li>
               <li>                  

               <a class="dropdown-item navi" href="/merchant_checkout">
                    <div class="d-flex flex-column">
                      <div class="d-flex justify-content-between align-items-center">
                        <span>Checkout</span>
                        <span class="format-float">` + subtotal + `</span>
                      </div>
                
                    </div>
                  </a>
                </li>`


                $(vv).html(html)

            })

            $("[minus-product-id]").each((i, v) => {
                var id = $(v).attr("minus-product-id")

                function minusItem() {
                    commerceApp_.minusItem_(id, true)
                    commerceApp_.components["updateMCart"]()
                    commerceApp_.toastChanges()
                }
                $(v)[0].onclick = minusItem
            })

            $("[delete-product-id]").each((i, v) => {
                var id = $(v).attr("delete-product-id")

                function deleteItem() {
                    commerceApp_.removeItem_(id, true)
                    commerceApp_.components["updateMCart"]()
                    commerceApp_.toastChanges()
                }
                $(v)[0].onclick = deleteItem
            })

            ColumnFormater.formatDate();

        },
        cart() {
            var count = 0,
                list = [],
                subtotal = 0.0;

            subtotal = commerceApp_.cart_.map((v, i) => {
                return (v.qty * v.retail_price)
            }).reduce((a, b) => {
                return a + b
            }, 0)
            count = commerceApp_.cart_.map((v, i) => {
                return v.qty
            }).reduce((a, b) => {
                return a + b
            }, 0)

            commerceApp_.cart_.forEach((v, i) => {
                var frp = `<div class="font-sm">RP <span class="font-sm format-float">` + (v.retail_price * v.qty).toFixed(2) + `</span></div>`
                if (!showRP) {
                    frp = `<div class="font-sm">MYR <span class="font-sm format-float">` + (v.retail_price * v.qty * phxApp_.chosen_country_id_.conversion).toFixed(2) + `</span></div>`

                }
                list.push(`

          <li><a class="dropdown-item" href="javascript:void(0);">
            <div style="width: 240px;" class="d-flex justify-content-between align-items-center">
              <span>` + v.name + ` <small>(x` + v.qty + `)</small></span>
              <div class="d-flex align-items-center justify-content-between gap-2">
               ` + frp + `


                <div class="d-lg-block d-none">
                  <div class="btn btn-sm" minus-product-id="` + v.id + `"><i class="text-danger fa fa-minus"></i></div>
                  <div class="btn btn-sm" delete-product-id="` + v.id + `"><i class="text-danger fa fa-times"></i></div>
                </div>

              </div>
            </div>

          </a></li>

            `)


            })

            if (list.length == 0) {

                list.push(`

          <li><a class="dropdown-item" href="javascript:void(0);">Empty</a></li>

            `)

            }
            var bg_ranks2 = [],
                sort = [];
            memberApp_.ranks.map((v, i) => {
                sort.push(v)
            })

            sort.sort((a, b) => {
                return a.retail_price - b.retail_price
            })

            sort.map((v, i) => {
                bg_ranks2.push(`
          <div class="col ">
            <div class="d-flex flex-column">
              <span>` + v.name + `</span>
              <span class="format-float">` + v.retail_price + `</span>
              
            </div>
          </div>`)
            })

            if ($("cartItems").attr("upgrade") != null) {
                subtotal = subtotal + memberApp_.user.rank.retail_price
            }
            eligible_rank = this.evalRank(subtotal)
            perc = subtotal / memberApp_.ranks[0].retail_price * 100

            $("cart").each((i, v) => {
                var needDropUp = `dropstart`

                if ($(v).attr("dropup") != null) {
                    needDropUp = `dropup`
                }
                $(v).customHtml(`
            <div class="` + needDropUp + `  ">
              <div class="mx-3 py-2 btn btn-outline-success rounded-xl position-relative"  data-bs-toggle="dropdown" aria-expanded="false">
                <div style="top: 4px !important;" class="badge bg-warning position-absolute top-0 start-100 translate-middle bc">` + count + `</div>
                <i class="fa fa-shopping-cart"></i>
              </div>
              <ul class="dropdown-menu dropdown-menu-end dropdown-menu-lg-start ac">
                ` + list.join("") + `
                <li id="divider">
                  <hr class="dropdown-divider">
                </li>
                <li>
                  <a class="dropdown-item navi" href="/register">
                    <div class="d-flex flex-column">
                      <div class="d-flex justify-content-between align-items-center">
                        <span>Checkout</span>
                        <span class="format-float">` + subtotal + `</span>
                      </div>
                   

                      <div class="d-flex justify-content-between align-items-center">
                        <small>Eligible</small>
                        <small class="text-info">` + eligible_rank + `</small>
                      </div>

                      <div class="progress my-2" style="height: 4px;">
                        <div class="progress-bar bg-success" role="progressbar" style="width: ` + perc + `%;" aria-valuenow="` + perc + `" aria-valuemin="0" aria-valuemax="100"></div>
                      </div>
                      <div class="row text-sm">
                        ` + bg_ranks2.join("") + `
                      </div>

                    
                    </div>
                  </a>
                </li>

              </ul>
            </div>
        `)
            })





            $("[minus-product-id]").each((i, v) => {
                var id = $(v).attr("minus-product-id")

                function minusItem() {
                    commerceApp_.minusItem_(id)
                    commerceApp_.components["updateCart"]()
                }
                $(v)[0].onclick = minusItem
            })

            $("[delete-product-id]").each((i, v) => {
                var id = $(v).attr("delete-product-id")

                function deleteItem() {
                    commerceApp_.removeItem_(id)
                    commerceApp_.components["updateCart"]()
                }
                $(v)[0].onclick = deleteItem
            })

            ColumnFormater.formatDate();

        },
        mcart() {
            var count = 0,
                list = [],
                subtotal = 0.0;

            subtotal = commerceApp_.mcart_.map((v, i) => {
                return (v.qty * v.retail_price)
            }).reduce((a, b) => {
                return a + b
            }, 0)
            count = commerceApp_.mcart_.map((v, i) => {
                return v.qty
            }).reduce((a, b) => {
                return a + b
            }, 0)

            commerceApp_.mcart_.forEach((v, i) => {

                list.push(`

          <li><a class="dropdown-item" href="javascript:void(0);">
            <div style="width: 240px;" class="d-flex justify-content-between align-items-center">
              <span>` + v.name + `<br><small>(x` + v.qty + `)</small></span>
              <div class="d-flex align-items-center justify-content-between gap-2">
                <span class="font-sm format-float">` + (v.retail_price * v.qty).toFixed(2) + `</span>


              </div>
            </div>

          </a></li>

            `)


            })

            if (list.length == 0) {

                list.push(`

          <li><a class="dropdown-item" href="javascript:void(0);">Empty</a></li>

            `)

            }



            $("mcart").each((i, v) => {
                var needDropUp = `dropstart`

                if ($(v).attr("dropup") != null) {
                    needDropUp = `dropup`
                }
                $(v).customHtml(`
            <div class="` + needDropUp + `  ">
              <div class="mx-3 py-2 btn btn-outline-danger rounded-xl position-relative"  data-bs-toggle="dropdown" aria-expanded="false">
                <div style="top: 4px !important;" class="badge bg-warning position-absolute top-0 start-100 translate-middle mbc">` + count + `</div>
                <i class="fa fa-shopping-cart"></i>
              </div>
              <ul class="dropdown-menu dropdown-menu-end dropdown-menu-lg-start mac">
                ` + list.join("") + `
                <li id="divider">
                  <hr class="dropdown-divider">
                </li>
                <li>
                  <a class="dropdown-item navi" href="/merchant_checkout">
                    <div class="d-flex flex-column">
                      <div class="d-flex justify-content-between align-items-center">
                        <span>Checkout</span>
                        <span class="format-float">` + subtotal + `</span>
                      </div>
                    </div>
                  </a>
                </li>

              </ul>
            </div>
        `)
            })





            $("[minus-product-id]").each((i, v) => {
                var id = $(v).attr("minus-product-id")

                function minusItem() {
                    commerceApp_.minusItem_(id, true)
                    commerceApp_.components["updateMCart"]()
                }
                $(v)[0].onclick = minusItem
            })

            $("[delete-product-id]").each((i, v) => {
                var id = $(v).attr("delete-product-id")

                function deleteItem() {
                    commerceApp_.removeItem_(id, true)
                    commerceApp_.components["updateMCart"]()
                }
                $(v)[0].onclick = deleteItem
            })

            ColumnFormater.formatDate();

        },
        light() {
            $("light").customHtml(`
              <div class=" py-2 btn btn-outline-success rounded-xl position-relative light"  >
                <i class="fa fa-lightbulb far"></i>
              </div>
        `)
                // $("html").attr("data-bs-theme", localStorage.get("data-bs-theme"))

            $(".light").unbind()
            $(".light").on("click", () => {

                if ($("html").attr("data-bs-theme") == "light") {

                    localStorage.setItem("data-bs-theme", "dark")
                    $("html").attr("data-bs-theme", "dark")
                } else {

                    localStorage.setItem("data-bs-theme", "light")
                    $("html").attr("data-bs-theme", "light")
                }

            })
        },
        product() {
            $("product").customHtml(`
          <div class="text-center mt-4">
            <div class="spinner-border loading2" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
          </div>
            
        <div class="loading2 d-none" id="pcontent" />
        `)

            phxApp_.api("get_product", {
                id: pageParams.id
            }, null, (data) => {
                $("title").html(data.name)

                function addToCart_() {

                    if (commerceApp_.first_cart_country_id == null && commerceApp_.cart_.length == 0) {
                        commerceApp_.first_cart_country_id = phxApp_.chosen_country_id_.id
                        console.log("first country id is " + phxApp_.chosen_country_id_.id)
                        localStorage.setItem("first_cart_country_id", phxApp_.chosen_country_id_.id)
                    }

                    console.info(check)
                    if (data.countries.map((vv, ii) => {
                            return vv.id
                        }).includes(parseInt(commerceApp_.first_cart_country_id))) {

                        commerceApp_.addItem_(data)
                        commerceApp_.components["updateCart"]()

                        phxApp_.notify("Added " + data.name, {
                            delay: 2000,
                            type: "success",
                            placement: {
                                from: "top",
                                align: "center"
                            }
                        })
                        phxApp_.toast({
                            content: `<div class=""><ul class="">` + $(".ac").html() + `</ul></div>`
                        })
                    } else if (commerceApp_.first_cart_country_id == null) {
                        commerceApp_.addItem_(data)
                        commerceApp_.components["updateCart"]()
                        phxApp_.notify("Added " + data.name, {
                            delay: 2000,
                            type: "success",
                            placement: {
                                from: "top",
                                align: "center"
                            }
                        })
                        phxApp_.toast({
                            content: `<div class=""><ul class="">` + $(".ac").html() + `</ul></div>`
                        })
                    } else {
                        phxApp_.notify("Not Added ! Please choose your region products.", {
                            delay: 2000,
                            type: "danger",
                            placement: {
                                from: "top",
                                align: "center"
                            }
                        })
                    }

                }

                $(".spinner-border.loading2").parent().remove()
                $(".loading2").removeClass("d-none")


                var img
                if (data.img_url != null) {

                    try {
                        img = data.img_url
                    } catch (e) {
                        img = '/images/placeholder.png'
                    }
                }



                var rp = `<div class="font-sm fw-light text-secondary text-center ">RP <span class="format-float">` + data.retail_price + `</span></div>`
                if (phxApp_.chosen_country_id_.name == "Malaysia") {
                    includeShippingTax = false
                } else {
                    includeShippingTax = true
                }
                if (includeShippingTax) {
                    rp = `<div class="font-sm fw-light text-secondary text-center "><span class="format-float">` + (data.retail_price * 1.1) + ` </span> RP</div>`
                    if (phxApp_.chosen_country_id_.name == "Singapore") {
                        rp = `<div class="font-sm fw-light text-secondary text-center "><span class="format-float">` + (data.retail_price * 1.05) + ` </span> RP</div>`

                    }

                    if (phxApp_.chosen_country_id_.name == "China" && ['DT2体验卡配套', 'DT2启动配套', '2张99次开机卡 DT2启动配套'].includes(data.name)) {

                        rp = `<div class="font-sm fw-light text-secondary text-center "><span class="format-float">` + (data.retail_price * 1.00) + ` </span> RP</div>`

                    }

                }


                if (!showRP) {
                    rp = `<div class="font-sm fw-light text-secondary text-center ">MYR <span class="format-float">` + (data.retail_price * phxApp_.chosen_country_id_.conversion) + `</span></div>`

                    if (phxApp_.chosen_country_id_.name == "Malaysia") {
                        includeShippingTax = false
                    } else {
                        includeShippingTax = true
                    }
                    if (includeShippingTax) {
                        rp = `<div class="font-sm fw-light text-secondary text-center ">MYR <span class="format-float">` + (data.retail_price * phxApp_.chosen_country_id_.conversion * 1.1) + `</span></div>`
                        if (phxApp_.chosen_country_id_.name == "Singapore") {
                            rp = `<div class="font-sm fw-light text-secondary text-center ">MYR <span class="format-float">` + (data.retail_price * phxApp_.chosen_country_id_.conversion * 1.05) + `</span></div>`

                        }
                    }

                }
                addBtn = `<div class="btn btn-outline-primary mt-4" product-id="` + data.id + `">Add</div>`
                if (data.instalment_packages.length > 0) {

                    var cards = []
                    data.instalment_packages.forEach((p, i) => {

                        c = `
              <div class=" col-12 col-lg-8 offset-lg-2 ">
                <div class="card m-4 p-4 ">
                  <div class="d-flex justify-content-between align-items-center">
                    <div class="fs-4">` + p.name + `</div>
                    <span class="d-flex flex-column">
                      <div class="text-secondary">` + p.retail_price + ` RP</div>
                      <div>` + p.point_value + ` PV</div> 
                    </span>
                    <span><div class="btn btn-outline-primary" product-id="` + p.id + `">Choose</div></span>
                  </div>
                </div>
              </div>

            `
                        cards.push(c)
                    })

                    addBtn = `<div class="row w-100">` + cards.join("") + `</div>`
                }


                $("#pcontent").customHtml(`

        <div class="d-flex flex-column justify-content-center align-items-center ">
          <h2 id="ptitle">
          </h2>
              <div  class="d-flex justify-content-center p-4 " 
                  style="
                    position: relative; 
                    width: 320px;
                    height: 340px;">
              <div class="rounded py-2" style="
                    height: 340px;
                    width: 88%;
                    filter: blur(4px);
                    position: absolute;
                    background-repeat: no-repeat;
                    background-position: center;
                    background-size: cover;
                    background-image: url('` + img + `');
                    top: 30px;
                    left: 20px;
                    ">
              </div>
              <div class="rounded py-2" style="
                    height: 340px;
                    width:  100%;
                    z-index: 1;
                    background-position: center;
                    background-repeat: no-repeat;
                    background-size: cover; 
                    background-image: url('` + img + `');
                    ">
              </div>
            </div>
          <div style="margin-top: 50px;">` + data.desc + `</div>
          ` + rp + `
          <div class="font-sm fw-light text-info text-center pv_label d-none">PV <span class="format-float">` + data.point_value + `</span></div>
          ` + addBtn + `
        </div>

        `)
                $("#ptitle").html(
                    data.name
                )
                try {

                    $("[product-id='" + data.id + "']")[0].onclick = addToCart_
                } catch (e) {

                }

            })


        },
        products() {
            function evalCountry(countryName) {
                var prefix = "v2"

                if (countryName == "Thailand") {
                    prefix = "th"
                }
                if (countryName == "Vietnam") {
                    prefix = "vn"
                }
                if (countryName == "China") {
                    prefix = "cn"
                }

                return prefix;
            }


            if (phxApp_.chosen_country_id_ == null) {
                var countries = []


                phxApp_.countries_.forEach((v, i) => {
                    countries.push(`
            <button type="button" aria-name="` + v.name + `" aria-country="` + v.id + `" class="btn btn-primary ">` + v.name + ` ` + (v.alias || "") + `</button>
          `)
                })
                phxApp_.modal({
                    selector: "#mySubModal",
                    content: `
          <center>
            <div class="btn-group-vertical">
            ` + countries.join("") + `
            </div>
          </center>
        `,
                    header: "Choose region",
                    autoClose: false
                })

                $("[aria-country]").unbind()
                $("[aria-country]").click(function() {
                    var country_id = $(this).attr("aria-country"),
                        name = $(this).attr("aria-name")
                    phxApp_.chosen_country_id_ = country_id
                    phxApp_.notify("Chosen region: " + name)
                    localStorage.setItem("region", name)
                    setTimeout(() => {

                        $("#chosen-region").html(name)
                    }, 1000)
                    if (localStorage.region != null) {
                        langPrefix = evalCountry(name)
                    }
                    translationRes = phxApp_.api("translation", {
                        lang: langPrefix
                    });


                    $("#mySubModal").modal('hide')
                    commerceApp_.components["country"]()
                        // commerceApp_.components["products"]()

                    if (pageParams.share_code != null) {
                        // commerceApp_.components["products"]()
                        phxApp_.api("get_share_link_by_code", {
                            code: pageParams.share_code
                        }, null, (sponsor) => {

                            commerceApp_.components["cartItems"]()

                            phxApp_.navigateTo(location.pathname)
                            $(".sponsor-name").customHtml("_sponsor: " + sponsor["user"]["username"] + " _position: " + sponsor.position)

                            $(".sponsor-bank").html(`

              <div class="d-flex justify-content-between align-items-center">
                <span class="fw-bold">Bank Details</span>
                <span class=" my-4 me-4 d-flex justify-content-end align-items-end gap-1 flex-column">
                  <div>` + sponsor["user"]["bank_name"] + `</div>
                  <div>` + sponsor["user"]["bank_account_holder"] + `</div>
                  <div>` + sponsor["user"]["bank_account_no"] + `</div>
                </span>
              </div>

                `)

                        })
                    } else {

                        phxApp_.navigateTo("/home")
                    }
                })

            }
            if (phxApp_.chosen_country_id_ != null) {
                function addToCart2_(dom) {
                    var id = $(dom).attr("product-id")

                    var data = phxApp_.api("get_product", {
                        id: id
                    })
                    try {
                        // var data = {}
                        if (commerceApp_.first_cart_country_id == null && commerceApp_.cart_.length == 0) {
                            commerceApp_.first_cart_country_id = phxApp_.chosen_country_id_.id
                            console.log("first country id is " + phxApp_.chosen_country_id_.id)
                            localStorage.setItem("first_cart_country_id", phxApp_.chosen_country_id_.id)
                        }

                        console.log(check)
                        if (data.countries.map((vv, ii) => {
                                return vv.id
                            }).includes(parseInt(commerceApp_.first_cart_country_id))) {

                            commerceApp_.selectedInstalment = data
                            commerceApp_.addItem_(data)
                            commerceApp_.components["updateCart"]()
                            commerceApp_.components["cartItems"]()


                            phxApp_.notify("Added " + data.name, {
                                    delay: 2000,
                                    type: "success",
                                    placement: {
                                        from: "top",
                                        align: "center"
                                    }
                                })
                                // phxApp_.toast({ content: `<div class=""><ul class="">` + $(".ac").html() + `</ul></div>` })
                        } else if (commerceApp_.first_cart_country_id == null) {
                            commerceApp_.selectedInstalment = data
                            commerceApp_.addItem_(data)
                            commerceApp_.components["updateCart"]()
                            commerceApp_.components["cartItems"]()
                            phxApp_.notify("Added " + data.name, {
                                    delay: 2000,
                                    type: "success",
                                    placement: {
                                        from: "top",
                                        align: "center"
                                    }
                                })
                                // phxApp_.toast({ content: `<div class=""><ul class="">` + $(".ac").html() + `</ul></div>` })
                        } else {
                            phxApp_.notify("Not Added ! Please choose your region products.", {
                                delay: 2000,
                                type: "danger",
                                placement: {
                                    from: "top",
                                    align: "center"
                                }
                            })
                        }

                    } catch (E) {
                        console.error(E)
                    }

                }


                $("products").each((i, products) => {

                    $(products).customHtml(`
            <div class="text-center mt-4">
              <div class="spinner-border loading" role="status">
                <span class="visually-hidden">Loading...</span>
              </div>
            </div>
              

            <div class="row gx-0 d-none loading">
              <div class="col-12 col-lg-10 offset-lg-1">
                <div id="product_tab1"></div>
              </div>
            </div>
          `).then(() => {

                        var customCols = null,
                            random_id = 'products',
                            productSource = new phoenixModel({
                                onDrawFn: () => {



                                    setTimeout(() => {
                                        $("[product-id]").each((i, v) => {
                                            v.onclick = () => {
                                                addToCart2_(v)
                                            }
                                        })
                                        ColumnFormater.formatDate()

                                        $(".spinner-border.loading").parent().remove()
                                        $(".loading").removeClass("d-none")
                                    }, 800)

                                },
                                xcard: (params) => {



                                    var data = params.product,
                                        showBtn = '',
                                        img = '/images/placeholder.png',
                                        onclickAttr = `onclick="phxApp.navigateTo('/products/` + data.id + `/` + data.name + `')"`;


                                    if ($(products).attr("direct") != null) {
                                        onclickAttr = ''
                                        showBtn = `<div class="btn btn-outline-primary mt-4" product-id="` + data.id + `">Add</div>`
                                    }
                                    if (data.img_url != null) {

                                        try {
                                            img = data.img_url
                                        } catch (e) {
                                            img = '/images/placeholder.png'
                                        }
                                    }


                                    var rp = `<div class="font-sm fw-light text-secondary text-center ">RP <span class="format-float">` + data.retail_price + `</span></div>`
                                    if (phxApp_.chosen_country_id_.name == "Malaysia") {
                                        includeShippingTax = false
                                    } else {
                                        includeShippingTax = true
                                    }
                                    if (includeShippingTax) {
                                        rp = `<div class="font-sm fw-light text-secondary text-center "><span class="format-float">` + (data.retail_price * 1.1) + `</span> RP</div>`

                                        if (phxApp_.chosen_country_id_.name == "Singapore") {

                                            rp = `<div class="font-sm fw-light text-secondary text-center "><span class="format-float">` + (data.retail_price * 1.05) + `</span> RP</div>`
                                        }

                                        if (phxApp_.chosen_country_id_.name == "China" && ['DT2体验卡配套', 'DT2启动配套', '2张99次开机卡 DT2启动配套'].includes(data.name)) {

                                            rp = `<div class="font-sm fw-light text-secondary text-center "><span class="format-float">` + (data.retail_price * 1.00) + `</span> RP</div>`


                                        }

                                    }
                                    if (!showRP) {
                                        rp = `<div class="font-sm fw-light text-secondary text-center ">MYR <span class="format-float">` + (data.retail_price * phxApp_.chosen_country_id_.conversion) + `</span></div>`

                                        if (phxApp_.chosen_country_id_.name == "Malaysia") {
                                            includeShippingTax = false
                                        } else {
                                            includeShippingTax = true
                                        }
                                        if (includeShippingTax) {
                                            rp = `<div class="font-sm fw-light text-secondary text-center ">MYR <span class="format-float">` + (data.retail_price * phxApp_.chosen_country_id_.conversion * 1.1) + `</span></div>`


                                            if (phxApp_.chosen_country_id_.name == "Singapore") {

                                                rp = `<div class="font-sm fw-light text-secondary text-center ">MYR <span class="format-float">` + (data.retail_price * phxApp_.chosen_country_id_.conversion * 1.05) + `</span></div>`
                                            }


                                        }
                                    }


                                    var card = `
            <div  class="m-2 d-flex flex-column gap-2" ` + onclickAttr + `>
              <div  class="d-flex justify-content-center mb-4 py-4 background-p" 
                    style="
                      cursor: pointer;   
                      position: relative; "
                     >
                <div class="rounded py-2 background-p" style="
                  
                      width: 80%;
                      filter: blur(4px);
                      position: absolute;
                      background-repeat: no-repeat;
                      background-position: center;
                      background-size: cover;
                      background-image: url('` + img + `');
                      
                      ">
                </div>
                <div class="rounded py-2 foreground-p" style="
                     
                      width:  100%;
                      z-index: 1;
                      background-position: center;
                      background-repeat: no-repeat;
                      background-size: contain; 
                      background-image: url('` + img + `');
                      ">
                </div>
              </div>
              <div class="d-flex flex-column justify-content-center gap-2 mt-4">
                <div class="font-sm fw-bold text-center">` + data.name + `</div>
                 <div class="d-flex flex-column justify-content-center ">
                    ` + rp + `
                    <div class="font-sm fw-light text-info text-center pv_label d-none">PV <span class="format-float">` + data.point_value + `</span></div>
                 </div>
                 ` + showBtn + `

             
              </div>
            </div>
            `
                                    return card
                                },
                                data: {
                                    pageLength: 12,
                                    sorts: [
                                        [2, "desc"]
                                    ],

                                    additional_join_statements: [{
                                        product: "product"
                                            // product_country: "product_country",

                                    }],
                                    additional_search_queries: [
                                        "b.is_instalment=false"
                                    ],

                                    country_id: phxApp_.chosen_country_id_.id,
                                    preloads: ["product"],
                                    grid_class: "col-4 col-lg-3",
                                    dom: `

                  <"row px-4"
                    <"col-lg-6 col-12"i>
                    <"col-12 col-lg-6">
                  >
                  <"row grid_view ">
                  <"list_view d-none"t>
                  <"row transform-75 px-4"
                    <"col-lg-6 col-12">
                    <"col-lg-6 col-12"p>
                  >

              `
                                },
                                columns: [

                                    {
                                        label: 'id',
                                        data: 'id'
                                    },

                                    {
                                        label: 'product_id',
                                        data: 'product_id'
                                    },

                                    // {
                                    //   label: 'retail_price',
                                    //   data: 'retail_price'
                                    // },

                                    {
                                        label: 'Action',
                                        data: 'id'
                                    }

                                ],
                                moduleName: "ProductCountry",
                                link: "ProductCountry",
                                customCols: customCols,
                                buttons: [],
                                tableSelector: "#" + random_id
                            })
                        productSource.load(random_id, "#product_tab1")

                    })


                })




            }






        },
        announcement() {
            try {

                $(".anc").slick('destroy')
            } catch (e) {

            }
            $("announcement").customHtml(`
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
        `)

            phxApp_.api("announcements", {

            }, null, (list) => {

                $("announcement").customHtml(``)

                list.forEach((v, i) => {

                    function showContent() {
                        phxApp_.modal({
                            selector: "#mySubModal",
                            content: v.content,
                            autoClose: false,
                            header: v.title
                        })
                    }


                    var url = v.img_url,
                        doc = `
            <div class="d-flex flex-column align-items-center" >

              <div class="d-flex justify-content-center " style="cursor: pointer;   
              position: relative; height: 240px;" announcement-id="` + v.id + `">
                <div class="sub rounded py-2" style="
                 
                    position: absolute;
                    filter: blur(10px); 
                                background-repeat: no-repeat;
                    background-position: center;
                    background-size: contain; 
                    background-image: url('` + url + `');
                   ">
                </div>
                <div class="su rounded py-2" style="
              
             

                    background-position: center;
                    background-repeat: no-repeat;
                    background-size: cover; 
                    background-image: url('` + url + `');
                    z-index: 1;
                    top: 16px;
                    position: absolute;">
                </div>
              </div>
              <span class="mt-3">` + v.title + `</span>
              <small>` + v.subtitle + `</small>
              
            </div>

          `

                    $("announcement").append(doc)

                    $("[announcement-id='" + v.id + "']")[0].onclick = showContent



                })

            })

            $(".anc").slick()
        },
        rewardList() {

            $("rewardList").each((rii, v) => {

                $(v).customHtml(`
          <div class="text-center mt-4">
            <div class="spinner-border loading" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
          </div>
            

          <div class="row gx-0 d-none loading">
            <div class="col-12">
              <div id="tab` + rii + `">No rewards</div>
            </div>
          </div>
        `)

                var isPrev = $(v).attr("prev") != null

                console.log(isPrev)

                phxApp_.api("get_reward_summary", {
                    user_id: memberApp_.user.id,
                    is_prev: isPrev
                }, null, (r) => {

                    $(".spinner-border.loading").parent().remove()
                    $(".loading").removeClass("d-none")
                    var rewards = ["sharing bonus", "team bonus", "matching bonus", "elite leader", "travel fund", "repurchase bonus", "drp sales level bonus", "stockist register bonus", "merchant sales level bonus", "biz incentive bonus", "matching biz incentive bonus"
                            // "royalty bonus"
                        ],
                        list = []
                    rewards.forEach((r2, ii) => {


                        r.forEach((v, i) => {
                            if (r2 == v.name) {

                                list.push(`

                                    <div class="my-2 d-flex align-items-center justify-content-between">

                                      <span class="fs-5">
                                        ` + ColumnFormater.capitalize(v.name) + `
                                      </span>
                                      <span class="d-flex justify-content-between gap-2 align-items-center">
                                        <span class="format-float">
                                          ` + v.sum + `
                                        </span>
                                        <a href="/reward_details/` + v.name + `/` + v.period[0] + `/` + v.period[1] + `" class="navi btn btn-primary btn-sm">
                                        <i class="fa fa-info"></i>
                                        </a>
                                      </span>
                                    </div>


                                `)

                            }
                        })
                    })

                    $("#tab" + rii).customHtml(`` + list.join("") + ``)
                    phxApp.formatDate()
                })
            })



        },
        rewardSummary() {

            $("rewardSummary").each((rii, v) => {

                $(v).customHtml(`
                      <div class="text-center mt-4">
                        <div class="spinner-border loading" role="status">
                          <span class="visually-hidden">Loading...</span>
                        </div>
                      </div>
                        

                      <div class="row gx-0 d-none loading">
                        <div class="col-12">
                          <div id="tabw` + rii + `">No rewards</div>
                        </div>
                      </div>
                    `)

                var isPrev = false

                console.log(isPrev)

                phxApp_.api("get_reward_summary_by_years", {
                    user_id: memberApp_.user.id
                }, null, (r) => {
                    var list = []

                    $(".spinner-border.loading").parent().remove()
                    $(".loading").removeClass("d-none")
                 console.log("testst")
                 var years = Object.keys(r["years"])


                      years.forEach((v, i) => {
                              list.push(`

                                    <div class="my-2 d-flex align-items-center justify-content-between">

                                      <span class="fs-5">
                                        ` + v + `
                                      </span>
                                      <span class="d-flex justify-content-between gap-2 align-items-center">
                                        <div>
                                        <span class="format-float">
                                          ` + r["years"][v][0].sum + ` 
                                        </span>
                                        BP
                                          </div>
                                          <a class="btn btn-primary btn-sm" target="_blank" href="/pdf?type=commission&id=`+memberApp_.user.id+`&year=`+v+`">
                                          Download
                                        </a>
                                      </span>
                                    </div>


                                `)
                        })


                      console.info(list)

                    $("#tabw" + rii).customHtml(``+list.join("")+``)
                    phxApp.formatDate()
                })
            })



        },
        wallet() {
            if (memberApp_.user != null) {

                var user = memberApp_.user,
                    wallets = phxApp_.api("user_wallet", {
                        token: user.token
                    })


                if (wallets.length == 0) {
                    $("wallet").parent().customHtml(`<div class="p-4">Wallet info expired</div>`)
                } else {

                    $("wallet").each((i, v) => {
                        var check = wallets.filter((wv, wi) => {
                            return wv.wallet_type == $(v).attr("aria-data")
                        })

                        if (check.length > 0) {

                            var wallet = check[0]


                            var wallet_name = $(v).attr("aria-data").split("_").map((v, i) => {
                                return ColumnFormater.capitalize(v)
                            }).join(" ")

                            var short_name = wallet_name.split(" ").map((i, v) => {
                                return i.split("")[0].toUpperCase()
                            }).join("") + "P"

                            $(v).customHtml(`
              <a href="/wallets/` + wallet.id + `" class="navi" >

              <div class=" card mb-3 mb-lg-0">
                <div style="
                  width: 4px;
                  position: absolute;
                  height: 100%;
                  background: rgb(251,254,253);
                  background: linear-gradient(45deg, rgb(86, 253, 197) 0%, rgb(218, 216, 216) 100%);

                " class="card-body p-0 "></div>
                <div class="card-body p-1 py-2 " style="width: 220px;">
                  <div class="d-flex gap-1 align-items-center">
                    <div wallet-id="` + wallet.id + `" class="d-none d-lg-block mx-2 py-2 btn btn-outline-success rounded-xl">
                      <i class=" fa fa-dollar-sign "></i>
                    </div>
                    <div class="ps-2 ps-lg-0">
                      <span class="text-sm text-secondary text-truncate">` + wallet_name + `, <b>` + short_name + `</b></span>
                      <div class="d-flex align-items-center gap-2">
                        <div class="fs-4 format-int" style="">` + wallet.total + `</div>
                        <small>pts</small>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="card-body p-0 d-none" style="

                  background: rgb(251,254,253);
                  background: linear-gradient(90deg, rgb(86, 253, 197) 0%, rgb(218, 216, 216) 100%);
                  height: 2px;

                "></div>
              </div>
              </a>

          `)
                        } else {

                        }



                    })
                }

                ColumnFormater.formatDate()
            }





        },
        userProfile() {


            var user = memberApp_.user;

            if (user) {

                var ranks = ["Bronze Package", "Silver Package", "Gold Package", "Shopper", "PreferredShopper"],
                    cranks = ["铜级套餐", "银级套餐", "金级套餐", "Shopper", "PreferredShopper"],
                    rank_name = user.rank != null ? user.rank.name : user.rank_name;

                var display_rank = ranks[cranks.indexOf(rank_name)]

                if (phxApp_.chosen_country_id_.name == "China") {
                    display_rank = rank_name
                }

                var name = user != null ? "Welcome! " + `<a href="/profile" class="navi">` + user.fullname + ` (` + display_rank + `)</a>` : `<a href="/login" class="navi">Login</a>`
                $("userProfile").customHtml(`
            
              ` + name + `
           
        `)
            } else {
                $("userProfile").customHtml(`
            
            <a href="/login" class="navi">Login</a>
           
        `)

            }
        },


    }

}