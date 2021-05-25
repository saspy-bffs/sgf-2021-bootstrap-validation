[![Apache 2.0 license](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)  [![Gitter](https://img.shields.io/gitter/room/saspy-bffs/community.svg?color=777777)](https://gitter.im/saspy-bffs/community)

# A Framework for Simple and Efficient Bootstrap Validation in SAS, with Examples


### Materials from an invited talk/paper for [SAS Global Forum](https://github.com/sascommunities/sas-global-forum-2021), held virtually on May 18-20, 2021.

Materials provided:

- [Full conference paper](Paper-SGF2021-Simple_and_Efficient_Bootstrap_Validation.pdf)

- [Slides](Slides-SGF2021-Simple_and_Efficient_Bootstrap_Validation.pdf) used in 20-minute pre-recorded video at [https://www.youtube.com/watch?v=Nrn7sFY2Zss](https://www.youtube.com/watch?v=Nrn7sFY2Zss)

- Four Examples:
  * Example 1 - PROC LOGISTIC (running example in conference paper and video) in [Jupyter Notebook](examples/Example1-PROC_LOGISTIC-SGF2021-Simple_and_Efficient_Bootstrap_Validation.ipynb) and [.sas](examples/Example1-PROC_LOGISTIC-SGF2021-Simple_and_Efficient_Bootstrap_Validation.sas) format
  * Example 2 - PROC LOGISTIC with Variable Selection (from Appendix C in conference paper) in [Jupyter Notebook](examples/Example2-PROC_LOGISTIC_with_Variable_Selection-SGF2021-Simple_and_Efficient_Bootstrap_Validation.ipynb) and [.sas](examples/Example2-PROC_LOGISTIC_with_Variable_Selection-SGF2021-Simple_and_Efficient_Bootstrap_Validation.sas) format
  * Example 3 - PROC HPLOGISTIC (from Appendix D in conference paper) in [Jupyter Notebook](examples/Example3-PROC_HPLOGISITIC-SGF2021-Simple_and_Efficient_Bootstrap_Validation.ipynb) and [.sas](examples/Example3-PROC_HPLOGISITIC-SGF2021-Simple_and_Efficient_Bootstrap_Validation.sas) format
  * Example 4 - PROC PHREG (from Appendix E in conference paper) in [Jupyter Notebook](examples/Example4-PROC_PHREG-SGF2021-Simple_and_Efficient_Bootstrap_Validation.ipynb) and [.sas](examples/Example4-PROC_PHREG-SGF2021-Simple_and_Efficient_Bootstrap_Validation.sas) format


## Prerequisites

Jupyter Notebook files for Examples 1-2 and 4 were developed using the JupyterLab interface for [SAS University Edition](https://www.sas.com/en_us/software/university-edition/download-software.html). Example 3 was developed in an independent installation of [JupyterLab](https://jupyter.org/install) using the [sas_kernel](https://github.com/sassoftware/sas_kernel) to connect to a local installation of SAS 9.4.

As of this writing, SAS University Edition is set to be retired on August 2, 2021. To use the Jupyter Notebook example files after this date, JupyterLab with the sas_kernel and a local installation of SAS 9.4 is recommended.

The .sas Example files should work in any relatively recent installation of SAS 9.4 with SAS/STAT. [SAS OnDemand for Academics](https://www.sas.com/en_us/software/on-demand-for-academics.html) might also be an option, but the authors have not tested this.


## License

This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.


## Authors

* [ilankham](https://github.com/ilankham)
* [mtslaugh](https://github.com/mtslaugh)


## Disclaimer

This project is in no way affiliated with SAS Institute Inc.
