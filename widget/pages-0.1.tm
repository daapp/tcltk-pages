package require Tk
package require Ttk
package require snit

package require widget::scrolledwindow

snit::widget widget::pages {
    hulltype ttk::frame

    variable pages [dict create]

    constructor args {
        # $self configurelist $args
    }


    method add {page args} {
        if {[dict exists $pages $page]} {
            return -code error "page \"$page\" already exists"
        } else {
            dict set pages $page $win.f$page

            ttk::frame $win.f$page
            place $win.f$page -x 0 -y 0 -relwidth 1 -relheight 1

            return $win.f$page
        }
    }

    method delete {page} {
        if {[dict exists $pages $page]} {
            destroy [dict get $pages $page]
            dict unset pages $page
        } else {
            return -code error "page \"$page\" does not exists"
        }
    }

    method pages {} {
        return [dict keys $pages]
    }

    method getpage {page} {
        if {[dict exists $pages $page]} {
            return [dict get $pages $page]
        }
    }

    method raise {page} {
        if {[dict exists $pages $page]} {
            raise [dict get $pages $page]
        }
    }
}

snit::widget widget::pagesmanager {
    hulltype ttk::frame

    variable pages [dict create]

    component pagesw
    component pagesList

    constructor args {
        widget::scrolledwindow $win.sw
        install pagesList using listbox $win.sw.pages -exportselection 0
        $win.sw setwidget $win.sw.pages

        install pagesw using widget::pages $win.pages

        pack $win.sw -side left -fill y
        pack $win.pages -side right -fill both -expand true

        bind $pagesList <<ListboxSelect>> [mymethod SwitchPage]
    }

    # args: -text msg
    method add {page args} {
        if {[dict exists $pages $page]} {
            return -code error "page \"$page\" already exists"
        } else {
            set text [from args -text $page]
            set path [$pagesw add $page]
            $pagesList insert end $text

            dict set pages $page $text

            return $path

        }
    }

    method delete {page} {
        if {[dict exists $pages $page]} {
            $pagesw delete $page
            dict unset pages $page
        } else {
            return -code error "page \"$page\" does not exists"
        }
    }

    method SwitchPage {} {
        set i [$pagesList curselection]

        set page [lindex [dict keys $pages] $i]
        $pagesw raise $page
    }

    delegate method raise to pagesw
}
