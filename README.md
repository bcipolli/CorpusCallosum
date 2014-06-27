NoisyCC
=======

Simulations, using Ringo et al. (1994) as a starting point, which:
* Show that the Ringo results only matter for the difference between the intra-hemispheric and inter-hemispheric conduction delays.
* Implement axon conduction delay noise
* Show that axon noise can cause interhemispheric independence
* Show that axon noise can suppress, or enhance, the development of lateralization, based on input/output lateralization.


Related Publications:

`Cipollini, B. and Cottrell, G.W. (2013) Uniquely human developmental timing may drive cerebral lateralization and interhemispheric coupling. In Proceedings of the 35th Annual Conference of the Cognitive Science Society. Austin, TX: Cognitive Science Society.`

References:


Adding new modules:

1. Add a new directory `DIR` to `code/_networks`, with the following 3 files: 

    a. 	`r_pats_DIR.m` - defines input patterns 
    b. 	`r_init_DIR.m` - defines the network structure (connections, weights, time constants) 
    c. 	`r_analyze_DIR.m` - defines the available analyses. 
2. Add a new directory `DIR` in `scripts`, and add a script file. 
3. Reset the following values in the script: 
    a. `net.sets.dataset = DIR` 
    b. `net.sets.init_type = DIR` 
