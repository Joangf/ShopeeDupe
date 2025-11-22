import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Login.css";
import TickingSuccess from "../components/Notifications/TickingSuccess"
import Log from "../components/AuthForm/Log"
import Register from "../components/AuthForm/Reg"
import OTP from "../components/AuthForm/OTP";
import Forgot from "../components/AuthForm/Forgot";
import Reset from "../components/AuthForm/Reset";
const API_URL = import.meta.env.VITE_BACKEND_URL;

// Updated LogoIcon with a dark stroke
const LogoIcon = () => (
  <svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M20 2.5L37.5 12.5V32.5L20 22.5L2.5 32.5V12.5L20 2.5Z" stroke="#222222" strokeWidth="2" strokeLinejoin="round"/>
    <path d="M2.5 12.5L20 22.5L37.5 12.5" stroke="#222222" strokeWidth="2" strokeLinejoin="round"/>
    <path d="M20 37.5V22.5" stroke="#222222" strokeWidth="2" strokeLinejoin="round"/>
  </svg>
);

const Login = ({setIsLoggedIn}) => {
  const [activeTab, setActiveTab] = useState("login");
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    username: "",
    password: "",
    firstName: "",
    lastName: "",
    email: "",
    role: "USER",
    confirmPassword: "",
    otp: ''
  });
  const [submitDone, setSubmitDone] = useState(false);
  const [invalidSubmit, setInvalidSubmit] = useState(false);
  const handleInputChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
    if(invalidSubmit) setInvalidSubmit(false);
  };

const handleSubmit = async (e) => {
  e.preventDefault();
  const doRequest = async (url, data, onSuccess) => {
    setIsLoading(true);
    try {
      const response = await fetch(`${API_URL}${url}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });

      if (response.ok && onSuccess) {
        onSuccess(response);
      }
      else{
        setInvalidSubmit(true);
      }
    } catch (error) {
      console.error("Request failed:", error);
    } finally {
      setIsLoading(false);
    }
  };

  if (activeTab === "register") {
    const { confirmPassword, otp, ...registerData } = formData;
    if (formData.password != formData.confirmPassword){
      return;
    }
    console.log("Register attempt:", registerData);

    await doRequest("/user", registerData, () => {
      setActiveTab("otp");
    });

  } else if (activeTab === "login") {
    const loginData = {identifier: formData.email,password: formData.password,}
    console.log("Login attempt:", loginData);

    await doRequest("/auth/login", loginData, async (response) => {
      const responseData = await response.json();
      localStorage.setItem('authToken', responseData.result.token);
      localStorage.setItem('idUser', responseData.result.id);
      setIsLoggedIn(true);
      sessionStorage.setItem('isLoggedIn', 'true');
      navigate("/");
    });
    

  } else if (activeTab === "forgot") {
    console.log("Forgot password for:", formData.email);
    await doRequest("/auth/forgot-password", formData.email, () => {
      setActiveTab("reset");
    });

  } else if (activeTab === "otp") {
    const { email, otp } = formData;
    const otpData = { email, otp };
    console.log("OTP attempt:", otpData);

    await doRequest("/verify/email", otpData, () => {
      setSubmitDone(true);  
      setTimeout(() => setSubmitDone(false), 2000);
      setActiveTab("login");
    });
  } else if (activeTab === "reset") {
    if (formData.password != formData.confirmPassword){
      return;
    }
    const tokenData = {token: formData.otp, password: formData.password}
    console.log("Reset attempt:", tokenData);
    await doRequest("/auth/reset-password", tokenData, () => {
      setSubmitDone(true);  
      setTimeout(() => setSubmitDone(false), 2000);
      setActiveTab("login");
    });
  }
};

  return (
    <div className="login-page">
      <TickingSuccess 
        isVisible={submitDone}
        message="Successful"
      />
      <div className="login-container">
        <div className="login-header">
          <button className="back-button" onClick={() => navigate("/")}>
            <svg
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                d="M15 18L9 12L15 6"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
            Back
          </button>
          <div className="logo-section">
            <LogoIcon />
            <div className="logo-text">
              <span className="logo-keazon">Dupe</span>
              {/* Changed "BOOKS" to "STORE" */}
              <span className="logo-books">STORE</span>
            </div>
          </div>
        </div>

        <div className="auth-content">
          <div className="auth-tabs">
            <button
              className={`tab-button ${activeTab === "login" ? "active" : ""}`}
              onClick={() => setActiveTab("login")}
            >
              Login
            </button>
            <button
              className={`tab-button ${
                activeTab === "register" ? "active" : ""
              }`}
              onClick={() => setActiveTab("register")}
            >
              Register
            </button>
          </div>

          <div className="auth-form-container">
            {activeTab === "login" && ( <Log 
              formData={formData}
              handleSubmit={handleSubmit}
              handleInputChange={handleInputChange}
              isLoading={isLoading}
              invalidSubmit={invalidSubmit}
              setActiveTab={setActiveTab}
            /> )}
            {activeTab === "register" && ( <Register 
              formData={formData}
              handleSubmit={handleSubmit}
              handleInputChange={handleInputChange}
              isLoading={isLoading}
              invalidSubmit={invalidSubmit}
            /> )}
            {activeTab === "forgot" && ( <Forgot 
              formData={formData}
              handleSubmit={handleSubmit}
              handleInputChange={handleInputChange}
              isLoading={isLoading}
              invalidSubmit={invalidSubmit}
              setActiveTab={setActiveTab}
            /> )}
            {activeTab === "otp" && ( <OTP 
              formData={formData}
              handleSubmit={handleSubmit}
              handleInputChange={handleInputChange}
              isLoading={isLoading}
              invalidSubmit={invalidSubmit}
              setActiveTab={setActiveTab}
            /> )}
            {activeTab === "reset" && ( <Reset 
              formData={formData}
              handleSubmit={handleSubmit}
              handleInputChange={handleInputChange}
              isLoading={isLoading}
              invalidSubmit={invalidSubmit}
              setActiveTab={setActiveTab}
            /> )}
          </div>

          {activeTab === "login" && (
            <div className="auth-footer">
              <span>Don't have an account? </span>
              <button
                className="link-button"
                onClick={() => setActiveTab("register")}
              >
                Sign up here
              </button>
            </div>
          )}

          {activeTab === "register" && (
            <div className="auth-footer">
              <span>Already have an account? </span>
              <button
                className="link-button"
                onClick={() => setActiveTab("login")}
              >
                Login here
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Login;