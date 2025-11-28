import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import "./UserProfilePage.css";
import Navbar from "../components/Home/Navbar";
import TickingFail from "../components/Notifications/TickingFail";
import Profile from "../components/UserProfile/Profile";
import DeleteAccountBox from "../components/UserProfile/DeleteAccountBox";
import SellerCenter from "../components/UserProfile/SellerCenter";
const API_URL = import.meta.env.VITE_BACKEND_URL;

const UserProfilePage = ({ isLoggedIn, setIsLoggedIn }) => {
  const navigate = useNavigate();
  const [activeDelete, setActiveDelete] = useState(false);
  const [formData, setFormData] = useState({
    fullName: "",
    gender: "",
    dateOfBirth: "",
    nationalId: "",
    email: "",
    phoneNumber: "",
    address: "",
  });
  const [activeTab, setActiveTab] = useState("profile");
  const handleInputChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const id = localStorage.getItem("idUser");
  const fetchUserData = async () => {
    try {
      const response = await fetch(`${API_URL}/user/${id}`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });
      const data = await response.json();
      console.log(data);
      setFormData({
        fullName: data.result.FullName || "",
        gender: data.result.Gender || "",
        dateOfBirth: data.result.DateOfBirth.split('T')[0] || "",
        nationalId: data.result.NationalID || "",
        email: data.result.Email || "",
        phoneNumber: data.result.PhoneNumber || "",
        address: data.result.Address || "",
      });
    } catch (error) {
      console.error("Error fetching user data:", error);
    }
  };
  useEffect(() => {
    fetchUserData();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    console.log("Form data:", formData);
    // Handle form submission
    const id = localStorage.getItem("idUser");
    try {
      const response = await fetch(`${API_URL}/user/${id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(formData),
      });
      if (response.ok) {
        alert("Profile updated successfully");
      }
    } catch (error) {
      console.error("Error fetching user data:", error);
    }
  };

  const handleDeleteAcc = async () => {
    const token = localStorage.getItem("authToken");
    try {
      const response = await fetch(`${API_URL}/user/${id}`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });
      if (response.ok) {
        localStorage.removeItem("authToken");
        localStorage.removeItem("idUser");
        localStorage.setItem("isLoggedIn", "false");
        setIsLoggedIn(false);
        navigate("/");
      }
    } catch (error) {
      console.error("Delete account failed:", error);
    }
  };

  const menuItems = [
    {
      id: "profile",
      label: "Profile",
      icon: (
        <svg
          width="30"
          height="30"
          viewBox="0 0 30 30"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M15 15C13.625 15 12.4479 14.5104 11.4688 13.5312C10.4896 12.5521 10 11.375 10 10C10 8.625 10.4896 7.44792 11.4688 6.46875C12.4479 5.48958 13.625 5 15 5C16.375 5 17.5521 5.48958 18.5312 6.46875C19.5104 7.44792 20 8.625 20 10C20 11.375 19.5104 12.5521 18.5312 13.5312C17.5521 14.5104 16.375 15 15 15ZM5 25V21.5C5 20.7917 5.18229 20.1406 5.54688 19.5469C5.91146 18.9531 6.39583 18.5 7 18.1875C8.29167 17.5417 9.60417 17.0573 10.9375 16.7344C12.2708 16.4115 13.625 16.25 15 16.25C16.375 16.25 17.7292 16.4115 19.0625 16.7344C20.3958 17.0573 21.7083 17.5417 23 18.1875C23.6042 18.5 24.0885 18.9531 24.4531 19.5469C24.8177 20.1406 25 20.7917 25 21.5V25H5ZM7.5 22.5H22.5V21.5C22.5 21.2708 22.4427 21.0625 22.3281 20.875C22.2135 20.6875 22.0625 20.5417 21.875 20.4375C20.75 19.875 19.6146 19.4531 18.4688 19.1719C17.3229 18.8906 16.1667 18.75 15 18.75C13.8333 18.75 12.6771 18.8906 11.5312 19.1719C10.3854 19.4531 9.25 19.875 8.125 20.4375C7.9375 20.5417 7.78646 20.6875 7.67188 20.875C7.55729 21.0625 7.5 21.2708 7.5 21.5V22.5ZM15 12.5C15.6875 12.5 16.276 12.2552 16.7656 11.7656C17.2552 11.276 17.5 10.6875 17.5 10C17.5 9.3125 17.2552 8.72396 16.7656 8.23438C16.276 7.74479 15.6875 7.5 15 7.5C14.3125 7.5 13.724 7.74479 13.2344 8.23438C12.7448 8.72396 12.5 9.3125 12.5 10C12.5 10.6875 12.7448 11.276 13.2344 11.7656C13.724 12.2552 14.3125 12.5 15 12.5Z"
            fill="black"
          />
        </svg>
      ),
    },
    {
      id: "seller",
      label: "Seller Center",
      icon: (
        <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="black">
          <path
            d="M856-390 570-104q-12 12-27 18t-30 6q-15 0-30-6t-27-18L103-457q-11-11-17-25.5T80-513v-287q0-33 23.5-56.5T160-880h287q16 0 31 6.5t26 17.5l352 353q12 12 17.5 27t5.5 30q0 15-5.5 29.5T856-390ZM513-160l286-286-353-354H160v286l353 354ZM260-640q25 0 42.5-17.5T320-700q0-25-17.5-42.5T260-760q-25 0-42.5 17.5T200-700q0 25 17.5 42.5T260-640Zm220 160Z"
          />
        </svg>        
      ),
    }
    // {
    //   id: "subscription",
    //   label: "Subscription",
    //   icon: (
    //     <svg
    //       width="26"
    //       height="26"
    //       viewBox="0 0 24 24"
    //       fill="none"
    //       xmlns="http://www.w3.org/2000/svg"
    //     >
    //       <path
    //         d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z"
    //         stroke="white"
    //         strokeWidth="2.5"
    //         strokeLinecap="round"
    //         strokeLinejoin="round"
    //       />
    //     </svg>
    //   ),
    // },
    // {
    //   id: 'account',
    //   label: 'Account',
    //   icon: (
    //     <svg width="26" height="26" viewBox="0 0 26 26" fill="none" xmlns="http://www.w3.org/2000/svg">
    //       <path d="M6.33746 18.525C7.25829 17.8208 8.28746 17.2656 9.42496 16.8593C10.5625 16.4531 11.7541 16.25 13 16.25C14.2458 16.25 15.4375 16.4531 16.575 16.8593C17.7125 17.2656 18.7416 17.8208 19.6625 18.525C20.2944 17.7847 20.7864 16.9451 21.1385 16.0062C21.4906 15.0673 21.6666 14.0652 21.6666 13C21.6666 10.5986 20.8225 8.55378 19.1343 6.86558C17.4461 5.17739 15.4013 4.33329 13 4.33329C10.5986 4.33329 8.55378 5.17739 6.86558 6.86558C5.17739 8.55378 4.33329 10.5986 4.33329 13C4.33329 14.0652 4.50933 15.0673 4.86142 16.0062C5.2135 16.9451 5.70552 17.7847 6.33746 18.525ZM13 14.0833C11.9347 14.0833 11.0364 13.7177 10.3052 12.9864C9.57392 12.2552 9.20829 11.3569 9.20829 10.2916C9.20829 9.22635 9.57392 8.32808 10.3052 7.59683C11.0364 6.86558 11.9347 6.49996 13 6.49996C14.0652 6.49996 14.9635 6.86558 15.6948 7.59683C16.426 8.32808 16.7916 9.22635 16.7916 10.2916C16.7916 11.3569 16.426 12.2552 15.6948 12.9864C14.9635 13.7177 14.0652 14.0833 13 14.0833ZM13 23.8333C11.5013 23.8333 10.093 23.5489 8.77496 22.9802C7.4569 22.4114 6.31038 21.6395 5.33538 20.6645C4.36038 19.6895 3.5885 18.543 3.01975 17.225C2.451 15.9069 2.16663 14.4986 2.16663 13C2.16663 11.5013 2.451 10.093 3.01975 8.77496C3.5885 7.4569 4.36038 6.31038 5.33538 5.33538C6.31038 4.36038 7.4569 3.5885 8.77496 3.01975C10.093 2.451 11.5013 2.16663 13 2.16663C14.4986 2.16663 15.9069 2.451 17.225 3.01975C18.543 3.5885 19.6895 4.36038 20.6645 5.33538C21.6395 6.31038 22.4114 7.4569 22.9802 8.77496C23.5489 10.093 23.8333 11.5013 23.8333 13C23.8333 14.4986 23.5489 15.9069 22.9802 17.225C22.4114 18.543 21.6395 19.6895 20.6645 20.6645C19.6895 21.6395 18.543 22.4114 17.225 22.9802C15.9069 23.5489 14.4986 23.8333 13 23.8333Z" fill="white"/>
    //     </svg>
    //   )
    // }
  ];

  const bottomMenuItems = [
    // ...
  ];
  if (!isLoggedIn)
    return <TickingFail isVisible={true} message="You needs to login first" />;
  return (
    <div className="profile-page industrial-theme">
      <Navbar
        isLoggedIn={isLoggedIn}
        setIsLoggedIn={setIsLoggedIn}
        activeCategories={[]}
      />
      {activeDelete && (
        <DeleteAccountBox
          onCancel={() => setActiveDelete(false)}
          onConfirm={handleDeleteAcc}
        />
      )}
      <div className="profile-container">
        {/* Sidebar */}
        <aside className="profile-sidebar">
          <div className="user-info">
            <div className="user-avatar">
              <img
                src="https://api.builder.io/api/v1/image/assets/TEMP/21e8c4ad58b36ddd2a9af3f8fa0325468a156350?width=160"
                alt="User Avatar"
              />
            </div>
            <div className="user-details">
              <h3 className="user-name">{formData.fullName}</h3>
            </div>
          </div>

          <nav className="sidebar-nav">
            {menuItems.map((item) => (
              <button
                key={item.id}
                className={`sidebar-nav-item ${
                  item.id === activeTab ? "active" : ""
                }`}
                onClick={() => setActiveTab(item.id)}
              >
                <span className="nav-icon">{item.icon}</span>
                <span className="nav-label">{item.label}</span>
              </button>
            ))}
          </nav>
        </aside>

        {/* Main Content */}
        {activeTab === "seller" && <SellerCenter formData={formData} setFormData={setFormData} />}
        {activeTab === "profile" && <Profile formData={formData} handleInputChange={handleInputChange} handleSubmit={handleSubmit} setActiveDelete={setActiveDelete}/>}
      </div>
    </div>
  );
};

export default UserProfilePage;
