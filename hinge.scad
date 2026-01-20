module hinge(
    pin_height     = 100,
    pin_radius     = 10, 
    pin_extend     = 5,
    nknuckles      = 3,
    knuckle_thk    = 10,
    pin_clearance  = 0.4,
    knuckle_z_gap  = 1.0,
    show_pin       = true,
    show_knuckles  = true,
    section_mode   = "none",   // "none", "half", "slice"
    section_thk    = 2.0,       // only used when section_mode == "slice"
    show_leaf_left = true,
    leaf_len       = 40,
    leaf_thk       = 4,
    leaf_gap       = 0.4,   // air gap between barrel and leaf plate
    tab_len        = 6      // how far the tab extends out to the plate
)
{
    model_r_max = pin_radius + pin_clearance + knuckle_thk;
    max_height = pin_height + (2 * pin_extend);
    
    if (section_mode == "none")
    {
        __draw_hinge_body();
    }
    else if (section_mode == "half")
    {
        difference()
        {
            __draw_hinge_body();
            __section_half_cut(model_r_max, pin_extend, max_height);
        }
    }
    else if (section_mode == "slice")
    {
        intersection()
        {
            __draw_hinge_body();
            __section_slice_cut( model_r_max, section_thk, pin_extend, max_height);
        }
    }
    else
    {
        __draw_hinge_body();
    }
    
    // =========================
    // Private 
    // =========================
    function __knuckle_h(pin_height, nknuckles, knuckle_z_gap) = (pin_height - ((nknuckles - 1) * knuckle_z_gap)) / nknuckles;
    
     module __draw_hinge_body()
    {
        if (show_pin == true)
        {
            __draw_hinge_pin(pin_radius, pin_extend, max_height);
        }
    
        if (show_knuckles == true)
        {
            __draw_hinge_knuckles(
                pin_height, 
                pin_radius, 
                pin_clearance, 
                knuckle_thk, 
                nknuckles, 
                knuckle_z_gap
            );
        }
        
        if (show_leaf_left == true)
        {
            __draw_leaf_left(
                pin_height,
                pin_radius,
                pin_clearance,
                knuckle_thk,
                nknuckles,
                knuckle_z_gap,
                leaf_len,
                leaf_thk,
                leaf_gap,
                tab_len
            );
        }
    }
    
    module __draw_hinge_pin(
        pin_radius,
        pin_extend,
        max_height
    )
    {
        translate([0, 0, -pin_extend])
            cylinder(
                h = max_height,
                r = pin_radius,
                center = false
            );
    }
    
    module __draw_hinge_knuckles(
        pin_height,
        pin_radius,
        pin_clearance,
        knuckle_thk,
        nknuckles,
        knuckle_z_gap
    )
    {
        knuckle_h = (pin_height - ((nknuckles - 1) * knuckle_z_gap)) / nknuckles;
        
        for (i = [0 : nknuckles - 1])
        {
            z0 = i * (knuckle_h + knuckle_z_gap);
            
            translate([0, 0, z0])
            difference()
            {
                cylinder(
                h = knuckle_h,
                r = pin_radius + pin_clearance + knuckle_thk,
                center = false
            );
            
            cylinder(
                h = knuckle_h,
                r = pin_radius + pin_clearance,
                center = false
            );
            }
        }
    }
    
    module __draw_leaf_left(
    pin_height,
    pin_radius,
    pin_clearance,
    knuckle_thk,
    nknuckles,
    knuckle_z_gap,
    leaf_len,
    leaf_thk,
    leaf_gap,
    tab_len
    )
    {
        outer_r   = pin_radius + pin_clearance + knuckle_thk;
        knuckle_h = __knuckle_h(pin_height, nknuckles, knuckle_z_gap);
        
        union()
        {
            __draw_leaf_left_plate(outer_r, pin_height, leaf_len, leaf_thk, leaf_gap);
        
            for (i = [0 : 2 : nknuckles - 1])   // 0,2,4,... (alternating)
            {
                z0 = i * (knuckle_h + knuckle_z_gap);
        
                __draw_leaf_left_tab(
                    outer_r,
                    leaf_gap,
                    tab_len,
                    leaf_thk,
                    z0,
                    knuckle_h
                );
            }
        }
    }

    module __draw_leaf_left_plate(outer_r, pin_height, leaf_len, leaf_thk, leaf_gap)
    {
        translate([outer_r + leaf_gap, -leaf_thk / 2, 0])
            cube([leaf_len, leaf_thk, pin_height], center = false);
    }
    
    module __draw_leaf_left_tab(outer_r, leaf_gap, tab_len, leaf_thk, z0, knuckle_h, eps = 0.2)
    {
        tab_x0 = outer_r - eps;
        tab_x1 = outer_r + leaf_gap + tab_len + eps;
        
        translate([tab_x0, -leaf_thk / 2, z0])
            cube([tab_x1 - tab_x0, leaf_thk, knuckle_h], center = false);
    }
    
    module __section_half_cut(
        model_r_max, 
        pin_extend, 
        max_height, 
        eps = 1)
    {
        translate([0, -(model_r_max + eps), -pin_extend - eps])
            cube(
                [model_r_max + eps,
                 (model_r_max + eps) * 2,
                 max_height + (2 * eps)],
                center = false
            );
    }
    
    module __section_slice_cut(
        model_r_max,
        section_thk,
        pin_extend,
        max_height,
        eps = 1
    )
    {
        translate(
            [-model_r_max - eps,
             -section_thk / 2,
             -pin_extend - eps]
        )
            cube(
                [(model_r_max + eps) * 2,
                 section_thk,
                 max_height + (2 * eps)],
                center = false
            );
    }
}
