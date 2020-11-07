Research Notes
================

## Study that inspired this project

  - [Caleb Robinson and Bistra Dilkina. 2018. A Machine Learning
    Approach to Modeling Human Migration. In Proceedings of the 1st ACM
    SIGCAS Conference on Computing and Sustainable Societies (COMPASS
    ’18). Association for Computing Machinery, New York, NY, USA,
    Article 30, 1–8.
    DOI:https://doi.org/10.1145/3209811.3209868](https://doi.org/10.1145/3209811.3209868)
      - Notes that gravity model is better for modeling migration at
        small spatial scales, like commuting flows, whereas radiation
        model is better for modeling migration at larger spatial scales,
        like migration flows.
      - Both “rely on linear relationships between independent
        variables” and both “trade predictive power for
        interpretability”
      - Should look more into their methods of comparing the 4 or 5
        models they inspect.
  - [Caleb Robinson’s Python library for working with migration
    data](https://github.com/calebrob6/migration-lib)
      - [MigrationModels.py](https://github.com/calebrob6/migration-lib/blob/master/MigrationModels.py)
        include python functions for a radiation model (line 70) and a
        gravity model (line 107). I’m comfortable enough with Python
        that I can probably interpret the steps those functions take in
        order to inform my approach in R.
          - His gravity model equation uses matrixes (different from the
            negative binomial regression approach below, may want to
            examine the differences)
          - His gravity model equation also requires users to specify if
            it uses power or exponential decay (what does that mean?)
          - Radiation model equation looks similar to the gravity one,
            but uses a different equation for computing P\[i, j\]
      - [US Migration
        Data](https://www.irs.gov/statistics/soi-tax-stats-migration-data)
      - README has some information on how to [download the
        data](https://github.com/calebrob6/migration-lib)

## Gravity Model Notes and Resources

  - **Need to choose to implement regression version or matrix
    version**  
  - [Wikipedia
    page](https://en.wikipedia.org/wiki/Gravity_model_of_migration)
      - Gravity model is derived from Newton’s law of gravity and I’ve
        worked with that formula before in physics. However, instead of
        measuring gravity between planets, the gravity model for
        migration estimates the degree of migration between two places.
      - Where the original equation uses “bodies” and “masses” of
        planets, the migration version uses “location” and “importance”.
        Both versions assume less interaction between two bodies or
        locations as the distance between them grows.
  - [Video about gravity model and
    migration](https://www.youtube.com/watch?v=5z_dlC0hxbQ)
      - Apparently the gravity model is covered in AP Human Geography.
      - Analogy between planets and big cities: greater mass /
        population == greater pull.
      - Equation: (population1 \* population2) / (distance^2)
      - Assumptions the model makes (that are not necessarily true):
        1.  uniform topography
        2.  uniform political boundaries, consumer preferences,
            transportation
        3.  no man-made boundaries to discourage migration
      - Gravity model is not perfect, doesn’t take into account factors
        that may pull people away from larger cities. The model mostly
        provides a way of estimating the chance that interaction will
        occur so we can apply this information to different situations.
  - [Video about types of migration and gravity model of
    migration](https://www.youtube.com/watch?v=4ZXQHg5F5o0)
      - Two types of migration: forced and voluntary.
      - Gravity model can be used to estimate voluntary migration, in
        which people move in response to push and pull factors.
      - Mentioned Ravenstein’s laws of migration, which i found the
        article for: [The Laws of
        Migration](https://cla.umn.edu/sites/cla.umn.edu/files/the_laws_of_migration.pdf)
          - Also found a [slide deck for Ravenstein’s laws of
            migration](http://www.mrtredinnick.com/uploads/7/2/1/5/7215292/ravensteins_laws_of_migration.pdf)
  - [Adam Crymble, “Introduction to Gravity Models of Migration &
    Trade,” The Programming Historian 8 (2019),
    https://doi.org/10.46430/phen0085.](https://programminghistorian.org/en/lessons/gravity-model)
      - A tutorial on how to implement a gravity model in R in order to
        use it for historical data analysis.
      - Their gravity model seems more complex than the basic equation
        from the AP Human Geography video: “A gravity model’s goal is to
        tell the user: given a number of influencing forces (distance,
        cost of living) affecting migration or movement of a large
        number of entities of the same type (people, coffee beans,
        widgets) between a set number of points (39 counties and London
        or Colombia and various countries), the model can suggest the
        most probable distribution of those people, coffee beans, or
        widgets. It operates on the principle that if you know the
        volume of movement, and you know the factors influencing it, you
        can predict with reasonable accuracy the outcome of even complex
        movement within a confined system.”
      - Took notes in a [google
        doc](https://docs.google.com/document/d/1FBXuk__Yepj9d9vOxqrgbQ1uiV_YX9pO3byxX1NB0vY/edit)
      - Their approach is to use a negative binomial regression model,
        which I could adapt to use for migration data beyond their case
        study (number of vagrants in the UK).
      - Downloaded their weightingCalculation.r script and it seems
        pretty simple to use and implement with great interpretability
        for migration modeling newbies like me
  - [Raul Ramos, “Gravity models: A tool for migration analysis,” IZA
    World of Labor (2016), doi:
    10.15185/izawol.239](https://wol.iza.org/uploads/articles/239/pdfs/gravity-models-tool-for-migration-analysis.pdf)
      - Listed many sources of data:
          - [UN Global Migration
            database](https://www.un.org/en/development/desa/population/migration/data/index.asp)
          - [The World Bank Global Bilateral Migration
            Database](https://datacatalog.worldbank.org/dataset/global-bilateral-migration-database)
          - [OECD International Migration
            Database](https://stats.oecd.org/Index.aspx?DataSetCode=MIG)
          - [CEPII Gravity Model
            Variables](http://www.cepii.fr/CEPII/en/publications/wp/abstract.asp?NoDoc=3877)
          - [UN International Migration
            Policies](https://www.un.org/en/development/desa/population/theme/policy/wpp2019.asp)
  - [Masucci, A & Serras, Joan & Johansson, Anders & Batty, Michael.
    (2013). “Gravity versus radiation models: On the importance of scale
    and heterogeneity in commuting flows.” Physical review. E,
    Statistical, nonlinear, and soft matter physics. 88. 022812.
    10.1103/PhysRevE.88.022812.](https://www.researchgate.net/publication/256607616_Gravity_versus_radiation_models_On_the_importance_of_scale_and_heterogeneity_in_commuting_flows)
      - Comparison between gravity and radiation models.

## Radiation Model Notes and Resources

  - [Wikipedia
    page](https://en.wikipedia.org/wiki/Radiation_law_for_human_mobility)

  - [Filippo Simini, Marta C González, Amos Maritan, and Albert-László
    Barabási.2012. A universal model for mobility and migration
    patterns. Nature 484, 7392
    (2012), 96–100.](https://www-nature-com.ezproxy.proxy.library.oregonstate.edu/articles/nature10856?message-global=remove&page=4)

  - [Yihui Ren, Mária Ercsey-Ravasz, Pu Wang, Marta C González, and
    Zoltán Toroczkai. 2014. Predicting commuter flows in spatial
    networks using a radiation model based on temporal ranges. Nature
    communications 5
    (2014).](https://www.nature.com/articles/ncomms6347)
    
      - Uses radiation model for modeling commuter traffic.

## Resources for Working with R

  - [R package for gravity models](https://pacha.dev/gravity/)
    
      - [Related paper about this
        package](https://www.ajs.or.at/index.php/ajs/article/view/688)
      - [Example
        code](https://pacha.dev/gravity/articles/crash-course-on-gravity-models.html)

  - [How to work with matrixes in
    R](https://www.datamentor.io/r-programming/matrix/)

  - [Another tutorial for working with matrixes in
    R](https://www.tutorialspoint.com/r/r_matrices.htm)
