#
# this module provide top menu and sidebar menu links
# filtered by current_ability
#
module MenuLinksViewHelper

  #
  # build menu based on bootstrap nav
  # format menu is listed below on top_menu_links method
  #
  def build_nav_menu(menus=[], options={})
    content_tag(:ul, {class: "nav navbar-nav"}.merge(options[:outer_ul] || {})) do
      menus.each do |menu| 
        #if menu is divider
        if (menu[:name] == 'divider')
          concat(content_tag(:li, class: 'divider') do;end)
        #if menu is logo
        elsif (menu[:name] == 'logo')
          concat(content_tag(:li, class: 'hidden-xs hidden-sm') do 
            concat(image_tag("logo.png", height: "50px", style: "padding-top: 20px;padding-right: 10px; padding-left: 10px; cursor: pointer;", "data-toggle" => "control-sidebar"))
          end)
        else
          #pop menu as <li>
          if menu[:is_presented]
            concat(content_tag(:li, class: "#{menu[:subs].present?? 'dropdown' : nil}" ) do
              concat(link_to(menu[:route], { "data-toggle" => "#{menu[:subs].present?? 'dropdown' : ''}", "aria-expanded" => "#{menu[:subs].present?? 'false' : ''}"}.merge!(menu[:options] || {}) ) do
                concat(content_tag(:i, class: menu[:icon]) do
                end)
                concat(content_tag(:span, class: 'hidden-xs hidden-sm') do 
                  concat(" #{menu[:name]}".html_safe)
                end)
                concat(if (menu[:subs].present?)
                  content_tag(:span, class: 'caret hidden-xs hidden-sm') do;end
                end)
              end)
              concat(if (menu[:subs].present?)
                build_nav_menu(menu[:subs], options={ outer_ul: { class: 'dropdown-menu', role: "menu" }})
              end)
            end)
          end
        end
      end
    end
  end

  #
  # build menu based on sidebar adminLTE style
  # format menu is listed below
  #
  def build_sidebar_menu menus=[], options={}
    content_tag :ul, class: 'sidebar-menu' do 
      # content for above main sidebar menu
      if block_given?
        concat(yield)
      end
      menus.each do |menu|
        if menu[:is_presented]
          concat(content_tag(:li, class: "#{menu[:subs].present?? 'treeview' : nil}") do 
            concat(link_to(menu[:route]) do 
              concat(content_tag(:i, "", class: "#{menu[:icon]}"))
              concat(content_tag(:span, menu[:name]))
            end)
            concat(if (menu[:subs].present?)
              content_tag(:ul, class: "treeview-menu") do
                concat(build_sidebar_menu(menu[:subs]))
              end
            end)
          end)
        end
      end
    end
  end
  
  #
  # return hash of top menu for specific user
  #
  def top_menu_links(tipe=:account)
    send("#{tipe}_top_menu_links") || [] 
  end

  #
  # return array of sidebar menu for spesific user
  #
  def sidebar_menu_links(tipe=:account)
    send("#{tipe}_sidebar_menu_links")
  end

  #
  # static list of menus methods
  #
  module StaticList

    def guest_top_menu_links
      [
        {
          name: "Home",
          is_presented: true,
          icon: "fa fa-home",
          route: root_path
        },
        {
          name: "API Documentation",
          icon: "fa fa-file-code-o",
          route: 'https://rss6.docs.apiary.io',#page_path('documentation'),
          is_presented: true
        }
      ]
    end

    #
    # top menu admin definitions
    #
    def account_top_menu_links
      [
        {
          name: current_account.try(:username),
          is_presented: true,
          route: '#',
          subs: [
            {
              name: "Logout",
              icon: 'fa fa-sign-out',
              route: destroy_account_session_path(),
              is_presented: true
            }
          ]

        }
      ]
    end

    #
    # account sidebar menu links
    #
    def account_sidebar_menu_links
      [
        {
          name: "Dashboard",
          is_presented: true,
          route: root_path,
          icon: "fa fa-dashboard",
        },
        {
          name: "Wallets",
          is_presented: true,
          icon: "fa fa-money",
          route: ripple_wallets_path
        },
        {
          name: "Plan",
          is_presented: true,
          icon: "fa fa-briefcase",
          route: plans_path
        },
        {
          name: "API Documentation",
          is_presented: true,
          icon: "fa fa-file-code-o",
          route: "https://rss6.docs.apiary.io"#page_path('documentation'),
        }
      ]
    end

    #
    # admin top menu links
    #
    def admin_sidebar_menu_links
      [
        {
          name: "Dashboard",
          is_presented: true,
          route: admin_path,
          icon: "fa fa-dashboard"
        },
        {
          name: "Accounts",
          is_presented: true,
          route: admin_accounts_path,
          icon: "fa fa-user"
        },
        {
          name: "Packages",
          is_presented: true,
          route: admin_plans_path,
          icon: "fa fa-rss-square"
        },
        {
          name: "Wallets",
          is_presented: true,
          route: admin_wallets_path,
          icon: "fa fa-money"
        },
        {
          name: "Transactions",
          is_presented: true,
          route: admin_transactions_path,
          icon: "fa fa-file"
        }
      ]
    end

    #
    # admin sidebar menu links
    #
    def admin_top_menu_links
      [
        {
          name: current_admin.try(:username),
          is_presented: true,
          route: '#',
          subs: [
            {
              name: "Account Setting",
              icon: "fa fa-lock",
              route: edit_admin_profile_path(current_admin, modal: {
                id: "modal-edit-profile-#{current_admin.id}",
                title: "Account Setting",
                template: "admin/profiles/edit",
                use_footer: true,
                submit_button_text: "Change",
                cancel_button_text: "Cancel",
                use_submit_footer_buttons: true
                }),
              is_presented: true,
              options: { remote: true }
            },
            {
              name: "Logout",
              icon: 'fa fa-sign-out',
              route: destroy_admin_session_path(),
              is_presented: true
            }
          ]

        }
      ]
    end

  end

  include MenuLinksViewHelper::StaticList

end

