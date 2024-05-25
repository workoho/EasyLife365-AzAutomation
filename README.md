<!-- Based on README.md template by https://github.com/othneildrew/Best-README-Template -->

<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
<div align="center">

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

</div>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/workoho/EasyLife365-AzAutomation">
    <img src="images/easylife365-logo.svg" alt="Logo" width="280">
  </a>

<h3 align="center">EasyLife 365 Azure Automation Kit</h3>

  <p align="center">
    Build custom automations for your <a href="https://www.easylife365.cloud/">EasyLife 365 suite</a> using Azure Automation.
    <br />
    <br />
    <a href="https://github.com/workoho/EasyLife365-AzAutomation/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
  </p>
</div>

<blockquote style="background-color: #e8f4fd; padding: 0.1em 1em 1em 1em; margin: 3.5em 0 3.5em 0;">
  <h3>Elevate Your Workflow with Workoho</h3>

  As the authorized partner and distributor of [EasyLife 365](https://www.easylife365.cloud/), Workoho is your gateway to seamless integration and optimization of Microsoft 365.

  **Discover the Potential:**
  Schedule a complimentary demo today and explore the transformative solutions EasyLife 365 offers.

  **Expertise at Your Service:**
  Need guidance? Our seasoned consultants are at the ready to tailor your internal processes, ensuring a perfect fit with Microsoft 365.

  **Connect with Workoho** – where efficiency meets excellence.

  [![Workoho][Workoho]][Workoho-url]
</blockquote>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

Using [webhooks](https://en.wikipedia.org/wiki/Webhook), EasyLife 365 provides a method for you to extend provisioning capabilities with custom logic. While this provides great flexibility, you may wonder about the right webhook endpoint you shall implement where you can securely run your own logic.

Besides using [Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-overview?pivots=programming-language-powershell), [Azure Automation](https://learn.microsoft.com/en-us/azure/automation/overview) is another option you may look into. This provides hybrid capabilities to integrate with your on-premises environment and long-running tasks. It also might feel more natural for administrators that are used to PowerShell scripting on their local machine.

In case you decide to use Azure Automation, this project can help you get up to speed in no time.
If you're familiar using the [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/), you will feel right at home. Using GitHub Codespaces, you get an easy way to start immediately without installing complex dependencies on your local machine. You can even start in your browser with no local dependency at all. PowerShell scripts (runbooks) can be developed and tested similar to what you are used to do during daily operation tasks already, which might feel more natural and less abstract to you.

#### Streamlined and Secure Setup Process

Our setup script is idempotent, meaning you can run it multiple times and it will always result in the same system state. It will guide you through the process and explain what minimum privileges are required for you. This makes it easy to comply with security requirements like following the [principle of least privilege](https://learn.microsoft.com/en-us/entra/identity-platform/secure-least-privileged-access). It will also manage peculiarities of Azure Automation where you don't need to spend time on.

#### Customizable Configuration for Your Automation Needs

A configuration file will allow to tailor everything to your specific needs. Besides setting the details of your Azure Automation account, it also allows to define permissions for the managed identity, define runtime environments with the appropriate PowerShell modules, or pre-define automation variables that your runbooks may use to help separating configuration from code.

#### Unified Codebase for All Dependencies

To allow a single infrastructure-as-code solution, we also provide capabilities to define a complex set of Microsoft Entra objects you may depend on. For example, you may define Administrative Units and create groups in them. In case your administrative unit is management restricted, it is interesting to know that you can also assign scopable Microsoft Entra roles to your setup user to ensure the setup script may continue to run properly.

### Built With

<div align="center">

[![Azure Automation Framework][AzAutoFW]][AzAutoFW-url]
[![GitHub Codespaces][GitHubCodespaces]][GitHubCodespaces-url]
[![Visual Studio Code][VScode]][VScode-url]
[![PowerShell][PowerShell]][PowerShell-url]

</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

The entire setup is fully automatic (thanks to the amazing [Azure Automation Common Runbook Framework](https://github.com/workoho/AzAuto-Common-Runbook-FW)), but requires some preparation and decision making to start.

### Prerequisites

We recommend to install [Visual Studio Code](https://code.visualstudio.com/docs/setup/setup-overview) locally on your machine for the best experience. However, you may also start right in your browser.

You also need a GitHub account to use [GitHub Codespaces](https://github.com/features/codespaces). The cost implications are rather small, GitHub Free or personal accounts get a few hours per month of free use (see [Billing for GitHub Codespaces](https://docs.github.com/en/billing/managing-billing-for-github-codespaces/about-billing-for-github-codespaces#monthly-included-storage-and-core-hours-for-personal-accounts)).

Alternatively, you may use any type of [development container](https://code.visualstudio.com/docs/devcontainers/containers) with your local Visual Studio Code setup. We provide pre-configured Docker containers for Windows Subsystem for Linux (Intel x64), Linux (Intel x64 and ARM64), and macOS (Intel x64 and Apple Silicon).

For further information, read [Choosing your development environment](https://code.visualstudio.com/docs/containers/choosing-dev-environment) at Visual Studio Code Docs.

### Installation

1. [Click here to create a new repository based on our template](https://github.com/new?template_name=EasyLife365-AzAutomation&template_owner=workoho). You may also [click here to fork this repository](https://github.com/workoho/EasyLife365-AzAutomation/fork), if you would like to keep the Git history.
2. Then, create a new codespace in your new repository. You can do so [directly from the GitHub web page](https://docs.github.com/en/codespaces/developing-in-a-codespace/creating-a-codespace-for-a-repository?tool=webui) of your repository, or in your [Visual Studio Code application on or local machine](https://docs.github.com/en/codespaces/developing-in-a-codespace/creating-a-codespace-for-a-repository?tool=vscode). We recommend using Visual Studio Code for the best experience.
3. The codespace will build automatically which takes some time. If you would like to have this pre-heated for the next time someone creates a new codespace, you may take a minute to setup [prebuilds](https://docs.github.com/en/codespaces/prebuilding-your-codespaces).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

## Usage

This section requires further attention. :-)

In general, you may have a look to the inline documentation of the runbooks if you would like to start with an idea.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## License

Distributed under the [CC-BY-SA-4.0 License](https://creativecommons.org/licenses/by-sa/4.0/). See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MAINTAINERS -->

## Maintainers

- Julian Pawlowski - [@jpawlowski](https://github.com/jpawlowski)

Project Link: [https://github.com/workoho/EasyLife365-AzAutomation](https://github.com/workoho/EasyLife365-AzAutomation)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/workoho/EasyLife365-AzAutomation.svg?style=for-the-badge
[contributors-url]: https://github.com/workoho/EasyLife365-AzAutomation/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/workoho/EasyLife365-AzAutomation.svg?style=for-the-badge
[forks-url]: https://github.com/workoho/EasyLife365-AzAutomation/network/members
[stars-shield]: https://img.shields.io/github/stars/workoho/EasyLife365-AzAutomation.svg?style=for-the-badge
[stars-url]: https://github.com/workoho/EasyLife365-AzAutomation/stargazers
[issues-shield]: https://img.shields.io/github/issues/workoho/EasyLife365-AzAutomation.svg?style=for-the-badge
[issues-url]: https://github.com/workoho/EasyLife365-AzAutomation/issues
[license-shield]: https://img.shields.io/github/license/workoho/EasyLife365-AzAutomation.svg?style=for-the-badge
[license-url]: https://github.com/workoho/EasyLife365-AzAutomation/blob/master/LICENSE.txt
[AzAutoFW]: https://img.shields.io/badge/Azure_Automation_Framework-1F4386?style=for-the-badge&logo=microsoftazure&logoColor=white
[AzAutoFW-url]: https://github.com/workoho/AzAuto-Common-Runbook-FW
[GitHubCodespaces]: https://img.shields.io/badge/GitHub_Codespaces-09091E?style=for-the-badge&logo=github&logoColor=white
[GitHubCodespaces-url]: https://github.com/features/codespaces
[VScode]: https://img.shields.io/badge/Visual_Studio_Code-2C2C32?style=for-the-badge&logo=visualstudiocode&logoColor=3063B4
[VScode-url]: https://code.visualstudio.com/
[PowerShell]: https://img.shields.io/badge/PowerShell-2C3C57?style=for-the-badge&logo=powershell&logoColor=white
[PowerShell-url]: https://microsoft.com/PowerShell
[Workoho]: https://img.shields.io/badge/Workoho.com-00B3CE?style=for-the-badge&logo=data:image/svg%2bxml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+Cjxzdmcgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEzNDggOTEzIiB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHhtbDpzcGFjZT0icHJlc2VydmUiIHhtbG5zOnNlcmlmPSJodHRwOi8vd3d3LnNlcmlmLmNvbS8iIHN0eWxlPSJmaWxsLXJ1bGU6ZXZlbm9kZDtjbGlwLXJ1bGU6ZXZlbm9kZDtzdHJva2UtbGluZWpvaW46cm91bmQ7c3Ryb2tlLW1pdGVybGltaXQ6MjsiPgogICAgPGcgdHJhbnNmb3JtPSJtYXRyaXgoNC4wNzQ3OCwwLDAsMy45NjAzOCwtNzQzMS4xNSwtNDYzNC44OCkiPgogICAgICAgIDxnPgogICAgICAgICAgICA8ZyB0cmFuc2Zvcm09Im1hdHJpeCg4LjY2MzI2ZS0xOCwwLjE0MTQ4MiwtMC4xNDE0ODIsOC42NjMyNmUtMTgsNDA1Ny43MiwtNDI5LjM1KSI+CiAgICAgICAgICAgICAgICA8cGF0aCBkPSJNMTI3MjYsMTM0NTIuN0wxMjc2Mi4zLDEzNDUyLjdMMTI5MzUuOCwxNDE2Ni40TDEyODk2LjEsMTQxNjYuNEwxMjcyNi44LDEzOTQ2LjRMMTI1NDMsMTM4OTAuM0wxMjcyNiwxMzQ1Mi43WiIvPgogICAgICAgICAgICA8L2c+CiAgICAgICAgICAgIDxnIHRyYW5zZm9ybT0ibWF0cml4KDAuMDg0NDk1NCwwLDAsMC4wODQ0OTU0LDE5NDEuOCwxMTA4LjU1KSI+CiAgICAgICAgICAgICAgICA8cGF0aCBkPSJNMTUxOC42MSwyOTk1LjQzTDExOTEuNDksMjk5NS40M0wxMDIyLjcsMzExMS40NkwxMDIyLjcsMzIxNS4wMUwxMjk3LjcsMzIxNS4wMUwxNTE4LjYxLDMwNjIuMDVMMTUxOC42MSwyOTk1LjQzWiIvPgogICAgICAgICAgICA8L2c+CiAgICAgICAgICAgIDxnIHRyYW5zZm9ybT0ibWF0cml4KDAuMDg0NDk1NCwwLDAsMC4wODQ0OTU0LDE4MTQuMDMsMTEwOC41NSkiPgogICAgICAgICAgICAgICAgPHBhdGggZD0iTTE5MTMuNDIsMjk5NS40M0wxMTkxLjQ5LDI5OTUuNDNMMTAyMi43LDMxMTEuNDZMMTAyMi43LDMyMTUuMDFMMTY5Mi41MiwzMjE1LjAxTDE5MTMuNDIsMzA2Mi4wNUwxOTEzLjQyLDI5OTUuNDNaIi8+CiAgICAgICAgICAgIDwvZz4KICAgICAgICA8L2c+CiAgICAgICAgPGc+CiAgICAgICAgICAgIDxnIHRyYW5zZm9ybT0ibWF0cml4KDAuMDg0NDk1NCwwLDAsMC4wODQ0OTU0LDE3MzEuODUsOTE3LjIxKSI+CiAgICAgICAgICAgICAgICA8cGF0aCBkPSJNMTkxMy40MiwyOTk1LjQzTDEyNTUuNzQsMjk5NS40M0wxMDg2Ljk0LDMxMTEuNDZMMTA4Ni45NCwzMjE1LjAxTDE2OTIuNTIsMzIxNS4wMUwxOTEzLjQyLDMwNjIuMDVMMTkxMy40MiwyOTk1LjQzWiIgc3R5bGU9ImZpbGw6d2hpdGU7Ii8+CiAgICAgICAgICAgIDwvZz4KICAgICAgICAgICAgPGcgdHJhbnNmb3JtPSJtYXRyaXgoMC45Mzc1NTgsMCwwLDAuOTM3NTU4LC00NzYwLjU0LC00MDgzLjg4KSI+CiAgICAgICAgICAgICAgICA8cGF0aCBkPSJNNzIwMi4xMiw1NjcxLjYzTDcyMDIuMTIsNTY4MC45TDcxNjMuNiw1NzIzLjM0TDcyNDAuODksNTgxOC43Mkw3MjQwLjg5LDU4MjcuOTlMNzIxMy40Myw1ODI3Ljk5TDcxMzkuNTMsNTczNy4wN0w3MTA0LjYxLDU3MzcuMDdMNzEwNC42MSw1ODI3Ljk5TDcwNzcuMzIsNTgyNy45OUw3MDc3LjMyLDU2MjMuOTFMNzEwNC42MSw1NjIzLjkxTDcxMDQuNjEsNTcwOS42MUw3MTM5LjUzLDU3MDkuNjFMNzE3NC42Niw1NjcxLjYzTDcyMDIuMTIsNTY3MS42M1oiIHN0eWxlPSJmaWxsOndoaXRlO2ZpbGwtcnVsZTpub256ZXJvOyIvPgogICAgICAgICAgICA8L2c+CiAgICAgICAgPC9nPgogICAgPC9nPgo8L3N2Zz4K
[Workoho-url]: https://workoho.com/
