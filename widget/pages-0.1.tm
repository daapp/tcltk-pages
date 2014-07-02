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


if {[info exists argv0] && [file tail [info script]] eq [file tail $argv0]} {

    labelframe .demopages -text "Pages demo"

    set pages [widget::pages .demopages.pages]
    set switch [frame .demopages.switch -bd 1]

    set colours {red yellow green}

    foreach i {1 2 3} {
        button $switch.sw$i -text page$i -command [list $pages raise page$i]
        pack $switch.sw$i -side left

        set f [$pages add page$i]

        lassign $colours c1 c2 c3

        button $f.$c1 -bg $c1 -text $c1
        button $f.$c2 -bg $c2 -text $c2
        button $f.$c3 -bg $c3 -text $c3

        pack $f.$c1 $f.$c2 $f.$c3 -side top -padx 5 -pady 5

        set colours [list $c2 $c3 $c1]
    }

    pack .demopages -fill both -expand true

    pack $switch -side top -fill y
    pack $pages -fill both -expand true

    $pages raise page1
}
