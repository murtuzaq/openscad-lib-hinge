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
    section_thk    = 2.0       // only used when section_mode == "slice"
)
{
    model_r_max = pin_radius + pin_clearance + knuckle_thk;
    max_height = pin_height + (2 * pin_extend);

    module __hinge_body()
    {
        if (show_pin == true)
        {
            translate([0, 0, -pin_extend])
                cylinder(
                    h = max_height,
                    r = pin_radius,
                    center = false
                );
        }

        if (show_knuckles == true)
        {
            knuckle_h =
                (pin_height - ((nknuckles - 1) * knuckle_z_gap))
                / nknuckles;

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
    }

    if (section_mode == "none")
    {
        __hinge_body();
    }
    else if (section_mode == "half")
    {
        difference()
        {
            __hinge_body();

            translate([0, -(model_r_max + 1), -pin_extend])
                cube([model_r_max + 1, (model_r_max + 1) * 2, max_height], center = false);
        }
    }
    else if (section_mode == "slice")
    {
        intersection()
        {
            __hinge_body();

            translate([-model_r_max - 1, -section_thk / 2, -1])
                cube([(model_r_max + 1) * 2, section_thk, pin_height + 2], center = false);
        }
    }
    else
    {
        __hinge_body();
    }
}
